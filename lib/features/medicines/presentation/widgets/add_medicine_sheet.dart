import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/medicine.dart';

class AddMedicineSheet extends StatefulWidget {
  const AddMedicineSheet({super.key});
  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  static const _colors = [
    AppTheme.blush,
    AppTheme.sky,
    AppTheme.mint,
    AppTheme.butter,
    Color(0xFFEDE2FA),
  ];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  int _intervalHours = 6;
  String _emoji = '🧸';
  Color _color = AppTheme.blush;
  bool _alreadyGiven = false;
  TimeOfDay _lastDoseTime = TimeOfDay.now();
  DateTime _lastDoseDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _lastDoseTime,
      helpText: 'Heure de la dernière dose',
    );
    if (value != null) setState(() => _lastDoseTime = value);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _lastDoseDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: 'Date de la dernière dose',
    );
    if (selected != null) setState(() => _lastDoseDate = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final lastGivenAt = _alreadyGiven
        ? DateTime(
            _lastDoseDate.year,
            _lastDoseDate.month,
            _lastDoseDate.day,
            _lastDoseTime.hour,
            _lastDoseTime.minute,
          )
        : null;
    if (lastGivenAt != null && lastGivenAt.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La dernière dose ne peut pas être dans le futur.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      Medicine(
        id: now.microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dose: _doseController.text.trim(),
        intervalHours: _intervalHours,
        emoji: _emoji,
        color: _color,
        lastGivenAt: lastGivenAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF4F7), AppTheme.background],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCCFD4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 19),
              const Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: AppTheme.blush,
                    child: Text('🌷', style: TextStyle(fontSize: 22)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nouveau petit soin',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink,
                          ),
                        ),
                        Text(
                          'Les informations médicales restent claires.',
                          style: TextStyle(fontSize: 12, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Indique le nom du médicament'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Nom du médicament',
                  prefixIcon: Icon(
                    Icons.medication_outlined,
                    color: AppTheme.roseDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doseController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Indique la dose exacte'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Dose exacte (ex. 2,5 mL)',
                  prefixIcon: Icon(
                    Icons.water_drop_outlined,
                    color: AppTheme.roseDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionLabel(
                label: 'Intervalle entre les doses',
                value: '${_intervalHours}h',
              ),
              Slider(
                value: _intervalHours.toDouble(),
                min: 1,
                max: 24,
                divisions: 23,
                activeColor: AppTheme.rose,
                inactiveColor: AppTheme.blush,
                label: '${_intervalHours}h',
                onChanged: (value) =>
                    setState(() => _intervalHours = value.round()),
              ),
              const SizedBox(height: 8),
              const Text(
                'Petit compagnon',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                children: ['🧸', '☀️', '🌈', '💊', '🦋']
                    .map(
                      (emoji) => ChoiceChip(
                        label: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        selected: _emoji == emoji,
                        selectedColor: _color,
                        side: BorderSide.none,
                        onSelected: (_) => setState(() => _emoji = emoji),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Couleur du carnet',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: _colors
                    .map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => _color = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == color
                                  ? AppTheme.roseDark
                                  : Colors.white,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 7,
                              ),
                            ],
                          ),
                          child: _color == color
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppTheme.roseDark,
                                )
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _alreadyGiven,
                      onChanged: (value) =>
                          setState(() => _alreadyGiven = value),
                      activeThumbColor: AppTheme.rose,
                      title: const Text(
                        'Dose déjà prise ?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Indique la date et l’heure pour calculer le rappel',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    if (_alreadyGiven) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today,
                          color: AppTheme.roseDark,
                        ),
                        title: const Text('Date de la dernière dose'),
                        trailing: TextButton(
                          onPressed: _pickDate,
                          child: Text(
                            '${_lastDoseDate.day}/${_lastDoseDate.month}/${_lastDoseDate.year}',
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.schedule_rounded,
                          color: AppTheme.roseDark,
                        ),
                        title: const Text('Heure de la dernière dose'),
                        trailing: TextButton(
                          onPressed: _pickTime,
                          child: Text(
                            _lastDoseTime.format(context),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        onTap: _pickTime,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text(
                    'Ajouter au carnet',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppTheme.ink,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.blush,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppTheme.roseDark,
          ),
        ),
      ),
    ],
  );
}

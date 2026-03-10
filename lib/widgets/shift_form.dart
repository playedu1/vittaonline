import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vittaonline/models/shift.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/providers/shifts_provider.dart';

class ShiftForm extends ConsumerStatefulWidget {
  final Shift? shift;

  const ShiftForm({super.key, this.shift});

  @override
  ConsumerState<ShiftForm> createState() => _ShiftFormState();
}

class _ShiftFormState extends ConsumerState<ShiftForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  ShiftStatus _status = ShiftStatus.scheduled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.shift != null) {
      _selectedUserId = widget.shift!.userId;
      _selectedDate = widget.shift!.date;
      _startTime = _parseTime(widget.shift!.startTime);
      _endTime = _parseTime(widget.shift!.endTime);
      _status = widget.shift!.status;
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um profissional.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profile = await ref.read(currentProfileProvider.future);
      if (profile == null) return;

      final shift = Shift(
        id: widget.shift?.id ?? '',
        userId: _selectedUserId!,
        clinicId: profile.clinicId,
        date: _selectedDate,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        status: _status,
      );

      if (widget.shift == null) {
        await ref.read(shiftsProvider.notifier).addShift(shift);
      } else {
        await ref.read(shiftsProvider.notifier).updateShift(shift);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving shift: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível completar a ação. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(availableStaffProvider);

    return AlertDialog(
      title: Text(widget.shift == null ? 'Novo Plantão' : 'Editar Plantão'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              staffAsync.when(
                data: (staff) => DropdownButtonFormField<String>(
                  value: _selectedUserId,
                  decoration: const InputDecoration(labelText: 'Profissional'),
                  items: staff.map((s) {
                    return DropdownMenuItem(
                      value: s['id'] as String,
                      child: Text(s['full_name'] as String),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedUserId = val),
                  validator: (val) => val == null ? 'Obrigatório' : null,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) {
                  if (kDebugMode) {
                    debugPrint('Error loading staff for shift form: $e');
                  }
                  return const Text('Não foi possível completar a ação. Tente novamente.');
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              ListTile(
                title: const Text('Início'),
                subtitle: Text(_startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) setState(() => _startTime = time);
                },
              ),
              ListTile(
                title: const Text('Fim'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) setState(() => _endTime = time);
                },
              ),
              DropdownButtonFormField<ShiftStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ShiftStatus.values.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.label),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

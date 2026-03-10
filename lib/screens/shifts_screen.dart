import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vittaonline/models/shift.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/providers/shifts_provider.dart';
import 'package:vittaonline/widgets/shift_form.dart';
import 'package:vittaonline/widgets/shift_status_badge.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  void _showShiftForm(BuildContext context, {Shift? shift}) {
    showDialog(
      context: context,
      builder: (context) => ShiftForm(shift: shift),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(shiftsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final profile = ref.watch(currentProfileProvider).value;
    final isAdmin = profile?.role.name == 'admin' || profile?.role.name == 'manager';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                ref.read(selectedDateProvider.notifier).state = date;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(context, selectedDate),
          const Divider(),
          Expanded(
            child: shiftsAsync.when(
              data: (shifts) => shifts.isEmpty
                  ? const Center(child: Text('Nenhum plantão para esta data.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: shifts.length,
                      itemBuilder: (context, index) {
                        final shift = shifts[index];
                        return _ShiftCard(shift: shift, isAdmin: isAdmin);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                if (kDebugMode) {
                  debugPrint('Shifts data error: $err');
                }
                return const Center(child: Text('Não foi possível completar a ação. Tente novamente.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showShiftForm(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final label = isToday ? 'Hoje' : DateFormat('EEEE, d MMMM', 'pt_BR').format(date);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ShiftCard extends ConsumerWidget {
  final Shift shift;
  final bool isAdmin;

  const _ShiftCard({required this.shift, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isAdmin ? () => _showShiftForm(context, shift: shift) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        shift.formattedTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ShiftStatusBadge(status: shift.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      shift.userName?.isNotEmpty == true
                          ? shift.userName!.split(' ').map((e) => e[0]).join('').substring(0, 2).toUpperCase()
                          : '??',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.userName ?? 'Profissional não identificado',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          shift.userRole ?? 'Cargo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'edit') {
                          _showShiftForm(context, shift: shift);
                        } else if (val == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: const Text('Deseja realmente excluir este plantão?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(shiftsProvider.notifier).deleteShift(shift.id);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShiftForm(BuildContext context, {Shift? shift}) {
    showDialog(
      context: context,
      builder: (context) => ShiftForm(shift: shift),
    );
  }
}

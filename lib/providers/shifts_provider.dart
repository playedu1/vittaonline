import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/models/shift.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/services/shift_service.dart';

final shiftServiceProvider = Provider<ShiftService>((ref) {
  return ShiftService();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

class ShiftsNotifier extends AsyncNotifier<List<Shift>> {
  @override
  FutureOr<List<Shift>> build() async {
    final date = ref.watch(selectedDateProvider);
    final profile = await ref.watch(currentProfileProvider.future);
    
    if (profile == null) return [];
    
    return ref.read(shiftServiceProvider).fetchShifts(profile.clinicId, date);
  }

  Future<void> addShift(Shift shift) async {
    await ref.read(shiftServiceProvider).createShift(shift);
    ref.invalidateSelf();
  }

  Future<void> updateShift(Shift shift) async {
    await ref.read(shiftServiceProvider).updateShift(shift);
    ref.invalidateSelf();
  }

  Future<void> deleteShift(String id) async {
    await ref.read(shiftServiceProvider).deleteShift(id);
    ref.invalidateSelf();
  }
}

final shiftsProvider = AsyncNotifierProvider<ShiftsNotifier, List<Shift>>(() {
  return ShiftsNotifier();
});

// Provider to fetch available staff for shift creation
final availableStaffProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return [];
  
  return ref.read(shiftServiceProvider).fetchAvailableStaff(profile.clinicId);
});

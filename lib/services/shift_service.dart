import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vittaonline/models/shift.dart';

class ShiftService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Shift>> fetchShifts(String clinicId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    final response = await _supabase
        .from('shifts')
        .select('*, profiles(full_name, role)')
        .eq('clinic_id', clinicId)
        .eq('date', dateStr)
        .order('start_time', ascending: true);

    return (response as List).map((json) => Shift.fromJson(json)).toList();
  }

  Future<void> createShift(Shift shift) async {
    await _supabase.from('shifts').insert(shift.toJson());
  }

  Future<void> updateShift(Shift shift) async {
    await _supabase
        .from('shifts')
        .update(shift.toJson())
        .eq('id', shift.id);
  }

  Future<void> deleteShift(String id) async {
    await _supabase.from('shifts').delete().eq('id', id);
  }

  // Helper to get profiles for selection in shift creation
  Future<List<Map<String, dynamic>>> fetchAvailableStaff(String clinicId) async {
    final response = await _supabase
        .from('profiles')
        .select('id, full_name, role')
        .eq('clinic_id', clinicId)
        .order('full_name', ascending: true);
    
    return response;
  }
}

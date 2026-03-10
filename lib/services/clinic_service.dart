import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vittaonline/models/clinic.dart';

class ClinicService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Clinic?> getClinic(String clinicId) async {
    final data = await _supabase
        .from('clinics')
        .select()
        .eq('id', clinicId)
        .single();
    
    return Clinic.fromJson(data);
  }

  Future<void> updateClinic(Clinic clinic) async {
    await _supabase
        .from('clinics')
        .update({
          'name': clinic.name,
          'address': clinic.address,
          'phone': clinic.phone,
        })
        .eq('id', clinic.id);
  }
}

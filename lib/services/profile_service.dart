import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vittaonline/models/profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    return Profile.fromJson(data);
  }

  Future<List<Profile>> getClinicStaff(String clinicId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('clinic_id', clinicId)
        .order('full_name');
    
    return (data as List).map((json) => Profile.fromJson(json)).toList();
  }

  Future<void> updateProfile(Profile profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  Future<void> updateLastActive(String userId) async {
    await _supabase
        .from('profiles')
        .update({
          'last_active': DateTime.now().toUtc().toIso8601String(),
          'status': 'online',
        })
        .eq('id', userId);
  }
}

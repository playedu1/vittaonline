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

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vittaonline/models/message.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Message>> fetchMessages(String clinicId, {int limit = 50}) async {
    final response = await _supabase
        .from('messages')
        .select('*, profiles(full_name, role)')
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => Message.fromJson(json)).toList();
  }

  Future<void> sendMessage({
    required String clinicId,
    required String content,
    String? mediaUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('messages').insert({
      'clinic_id': clinicId,
      'user_id': user.id,
      'content': content,
      'media_url': mediaUrl,
    });
  }

  Stream<List<Message>> subscribeToMessages(String clinicId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Message.fromJson(json)).toList());

    // Note: The simple .stream() doesn't automatically join profiles.
    // In a real app, we might want to use a different approach for realtime joins
    // or handle profile fetching separately in the provider.
  }

  Future<String?> uploadMedia(
    String clinicId,
    String fileName,
    Uint8List fileBytes,
    String mimeType,
  ) async {
    final path = '$clinicId/$fileName';

    await _supabase.storage
        .from('chat-media')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(contentType: mimeType),
        );

    return _supabase.storage.from('chat-media').getPublicUrl(path);
  }
}

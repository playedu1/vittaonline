import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/models/message.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/services/message_service.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});

class MessagesNotifier extends AsyncNotifier<List<Message>> {
  @override
  FutureOr<List<Message>> build() async {
    final profile = await ref.watch(currentProfileProvider.future);
    if (profile == null) return [];

    // Initial fetch
    final messages = await ref.read(messageServiceProvider).fetchMessages(profile.clinicId);

    // Subscribe to realtime updates
    _subscribeToUpdates(profile.clinicId);

    return messages;
  }

  void _subscribeToUpdates(String clinicId) {
    ref.read(messageServiceProvider).subscribeToMessages(clinicId).listen((newMessages) {
      // Since the stream returns the whole list, we can just update the state
      // But if we want to be more efficient, we might want to handle only inserts
      state = AsyncData(newMessages);
    });
  }

  Future<void> sendMessage(String content, {String? mediaUrl}) async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) return;

    await ref.read(messageServiceProvider).sendMessage(
          clinicId: profile.clinicId,
          content: content,
          mediaUrl: mediaUrl,
        );
    
    // The realtime subscription will update the list
  }
}

final messagesProvider = AsyncNotifierProvider<MessagesNotifier, List<Message>>(() {
  return MessagesNotifier();
});

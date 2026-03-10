import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/models/message.dart';
import 'package:vittaonline/models/profile.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/services/message_service.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});

class MessagesNotifier extends AsyncNotifier<List<Message>> {
  final Map<String, Profile> _profileCache = {};
  StreamSubscription? _subscription;

  @override
  FutureOr<List<Message>> build() async {
    final profile = await ref.watch(currentProfileProvider.future);
    
    ref.onDispose(() {
      _subscription?.cancel();
    });

    if (profile == null) return [];

    // Initial fetch
    final messages = await ref
        .read(messageServiceProvider)
        .fetchMessages(profile.clinicId);

    // Subscribe to realtime updates
    _subscribeToUpdates(profile.clinicId);

    return messages;
  }

  void _subscribeToUpdates(String clinicId) {
    _subscription?.cancel();
    _subscription = ref.read(messageServiceProvider).subscribeToMessages(clinicId).listen((
      newMessages,
    ) async {
      final enrichedMessages = await _enrichMessages(newMessages);
      state = AsyncData(enrichedMessages);
    });
  }

  Future<List<Message>> _enrichMessages(List<Message> messages) async {
    final List<Message> enriched = [];

    for (var msg in messages) {
      // If profile info is missing, try to get it from cache or service
      if (msg.senderName == null) {
        Profile? profile = _profileCache[msg.senderId];

        if (profile == null) {
          try {
            profile = await ref
                .read(profileServiceProvider)
                .getProfile(msg.senderId);
            if (profile != null) {
              _profileCache[msg.senderId] = profile;
            }
          } catch (e) {
            // Silently ignore profile fetch errors
          }
        }

        if (profile != null) {
          enriched.add(
            msg.copyWith(
              senderName: profile.fullName,
              senderRole: profile.role.name,
            ),
          );
          continue;
        }
      }
      enriched.add(msg);
    }

    return enriched;
  }

  Future<void> sendMessage(String content, {String? mediaUrl}) async {
    final profile = await ref.read(currentProfileProvider.future);
    if (profile == null) return;

    await ref
        .read(messageServiceProvider)
        .sendMessage(
          clinicId: profile.clinicId,
          content: content,
          mediaUrl: mediaUrl,
        );

    // The realtime subscription will update the list
  }
}

final messagesProvider = AsyncNotifierProvider<MessagesNotifier, List<Message>>(
  () {
    return MessagesNotifier();
  },
);

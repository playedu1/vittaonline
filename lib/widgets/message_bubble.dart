import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vittaonline/config/theme.dart';
import 'package:vittaonline/models/message.dart';
import 'package:vittaonline/widgets/role_badge.dart';
import 'package:vittaonline/models/profile.dart'; 

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 36, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.senderName ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (message.senderRole != null)
                    RoleBadge(
                      role: UserRole.values.byName(message.senderRole!),
                      isSmall: true,
                    ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: VittaOnlineTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    message.senderName?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: VittaOnlineTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? VittaOnlineTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.mediaUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: message.mediaUrl!,
                            placeholder: (context, url) => Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/config/theme.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/widgets/role_badge.dart';
import 'package:vittaonline/widgets/online_indicator.dart';
import 'package:vittaonline/models/profile.dart';

class UserHeader extends ConsumerWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: profileAsync.when(
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();

          return Row(
            children: [
              CircleAvatar(
                backgroundColor: VittaOnlineTheme.primaryColor.withValues(alpha: 0.1),
                radius: 20,
                child: Text(
                  profile.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: VittaOnlineTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        OnlineIndicator(isOnline: profile.status == UserStatus.online),
                        const SizedBox(width: 6),
                        RoleBadge(role: profile.role, isSmall: true),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.logout_rounded, size: 20),
                onPressed: () => ref.read(authServiceProvider).signOut(),
                color: Colors.grey[600],
                tooltip: 'Sair',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, st) => const Icon(Icons.error_outline, color: VittaOnlineTheme.alertColor),
      ),
    );
  }
}

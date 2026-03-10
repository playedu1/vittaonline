import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vittaonline/config/theme.dart';
import 'package:vittaonline/widgets/user_header.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: VittaOnlineTheme.backgroundColor.withValues(alpha: 0.8),
            border: const Border(
              right: BorderSide(color: VittaOnlineTheme.borderColor, width: 1),
            ),
          ),
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  color: VittaOnlineTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'VittaOnline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: VittaOnlineTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat Geral',
                  isActive: location == '/chat',
                  onTap: () => context.go('/chat'),
                ),
                _SidebarItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Lista de Plantão',
                  isActive: location == '/shifts',
                  onTap: () => context.go('/shifts'),
                ),
                _SidebarItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Painel Admin',
                  isActive: location.startsWith('/admin'),
                  onTap: () => context.go('/admin'),
                ),
              ],
            ),
          ),
          const UserHeader(),
        ],
      ),
    ),
  ),
);
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? VittaOnlineTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? VittaOnlineTheme.primaryColor : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? VittaOnlineTheme.primaryColor : Colors.grey[800],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vittaonline/config/theme.dart';
import 'package:vittaonline/models/profile.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool isSmall;

  const RoleBadge({
    super.key,
    required this.role,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (role) {
      case UserRole.admin:
        color = VittaOnlineTheme.primaryColor;
        label = 'Admin';
      case UserRole.dentista:
        color = VittaOnlineTheme.successColor;
        label = 'Dentista';
      case UserRole.medico:
        color = Colors.purple;
        label = 'Médico';
      case UserRole.recepcionista:
        color = Colors.orange;
        label = 'Recepcionista';
      case UserRole.auxiliar:
        color = Colors.teal;
        label = 'Auxiliar';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: isSmall ? 8 : 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vittaonline/config/theme.dart';

class OnlineIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const OnlineIndicator({
    super.key,
    required this.isOnline,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? VittaOnlineTheme.successColor : Colors.grey[400],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          if (isOnline)
            BoxShadow(
              color: VittaOnlineTheme.successColor.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }
}

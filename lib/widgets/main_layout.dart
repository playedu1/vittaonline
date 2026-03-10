import 'package:flutter/material.dart';
import 'package:vittaonline/widgets/sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

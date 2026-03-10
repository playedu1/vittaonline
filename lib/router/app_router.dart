import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/screens/login_screen.dart';

import 'package:vittaonline/widgets/main_layout.dart';

final appRouter = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/chat',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authStateAsync.isLoading) return null;

      final authState = authStateAsync.value;
      final isAuthenticated = authState?.session != null;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/chat';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('VittaOnline - Chat Screen (Phase 4)')),
            ),
          ),
          GoRoute(
            path: '/shifts',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('VittaOnline - Shifts Screen (Phase 5)')),
            ),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('VittaOnline - Admin Screen (Phase 6)')),
            ),
          ),
        ],
      ),
    ],
  );
});

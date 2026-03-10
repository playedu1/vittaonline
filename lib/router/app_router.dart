import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/screens/login_screen.dart';

import 'package:vittaonline/screens/chat_screen.dart';
import 'package:vittaonline/screens/shifts_screen.dart';
import 'package:vittaonline/screens/admin_screen.dart';
import 'package:vittaonline/models/profile.dart';
import 'package:vittaonline/widgets/main_layout.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final appRouter = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);
  final authStateAsync = ref.watch(authStateProvider);
  final profileAsync = ref.watch(currentProfileProvider);

  return GoRouter(
    initialLocation: '/chat',
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (authStateAsync.isLoading || profileAsync.isLoading) {
        return null;
      }

      final authState = authStateAsync.value;
      final isAuthenticated = authState?.session != null;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/chat';
      }

      // Role-based access control for /admin
      if (state.uri.path == '/admin') {
        final profile = profileAsync.value;
        final isAdmin = profile?.role == UserRole.admin;
        if (!isAdmin) {
          return '/chat';
        }
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
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/shifts',
            builder: (context, state) => const ShiftsScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminScreen(),
          ),
        ],
      ),
    ],
  );
});

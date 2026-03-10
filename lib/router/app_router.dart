import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/screens/login_screen.dart';

import 'package:vittaonline/screens/chat_screen.dart';
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

  return GoRouter(
    initialLocation: '/chat',
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authStateAsync.isLoading) {
        debugPrint('GoRouter: Auth state is loading...');
        return null;
      }

      final authState = authStateAsync.value;
      final isAuthenticated = authState?.session != null;
      final isLoggingIn = state.uri.path == '/login';

      debugPrint('GoRouter: redirect check - path: ${state.uri.path}, authenticated: $isAuthenticated');

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
        builder: (context, state) {
          debugPrint('GoRouter: building LoginScreen');
          return const LoginScreen();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          debugPrint('GoRouter: building ShellRoute (MainLayout)');
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/chat',
            builder: (context, state) {
              debugPrint('GoRouter: building ChatScreen');
              return const ChatScreen();
            },
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

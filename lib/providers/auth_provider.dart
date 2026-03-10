import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vittaonline/services/auth_service.dart';
import 'package:vittaonline/models/profile.dart';
import 'package:vittaonline/services/profile_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session ?? Supabase.instance.client.auth.currentSession;
});

final userProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;
  return ref.read(profileServiceProvider).getProfile(user.id);
});

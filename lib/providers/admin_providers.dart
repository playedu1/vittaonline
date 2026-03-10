import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/models/clinic.dart';
import 'package:vittaonline/models/profile.dart';
import 'package:vittaonline/providers/auth_provider.dart';
import 'package:vittaonline/services/clinic_service.dart';

final clinicServiceProvider = Provider<ClinicService>((ref) {
  return ClinicService();
});

final currentClinicProvider = FutureProvider<Clinic?>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return null;
  return ref.read(clinicServiceProvider).getClinic(profile.clinicId);
});

final staffProvider = FutureProvider<List<Profile>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return [];
  return ref.read(profileServiceProvider).getClinicStaff(profile.clinicId);
});

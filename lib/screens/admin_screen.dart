import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vittaonline/config/theme.dart';
import 'package:vittaonline/providers/admin_providers.dart';
import 'package:vittaonline/providers/auth_provider.dart';

import 'package:vittaonline/models/profile.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Painel Admin'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: VittaOnlineTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: VittaOnlineTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.business_rounded), text: 'Clínica'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Profissionais'),
            Tab(icon: Icon(Icons.person_outline_rounded), text: 'Meu Perfil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ClinicSettingsTab(),
          StaffManagementTab(),
          UserProfileTab(),
        ],
      ),
    );
  }
}

class ClinicSettingsTab extends ConsumerStatefulWidget {
  const ClinicSettingsTab({super.key});

  @override
  ConsumerState<ClinicSettingsTab> createState() => _ClinicSettingsTabState();
}

class _ClinicSettingsTabState extends ConsumerState<ClinicSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final clinicAsync = ref.read(currentClinicProvider);
    final clinic = clinicAsync.value;
    if (clinic == null) return;

    setState(() => _isLoading = true);
    try {
      final updatedClinic = clinic.copyWith(
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
      );
      await ref.read(clinicServiceProvider).updateClinic(updatedClinic);
      ref.invalidate(currentClinicProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações salvas com sucesso!')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving clinic settings: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível completar a ação. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicAsync = ref.watch(currentClinicProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return clinicAsync.when(
      data: (clinic) {
        if (clinic == null) return const Center(child: Text('Clínica não encontrada.'));

        // Initialize controllers once
        if (_nameController.text.isEmpty && clinic.name.isNotEmpty) {
          _nameController.text = clinic.name;
          _addressController.text = clinic.address ?? '';
          _phoneController.text = clinic.phone ?? '';
        }

        final isAdmin = profileAsync.value?.role == UserRole.admin;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informações da Clínica',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: VittaOnlineTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                const Text('Estes dados serão exibidos nos relatórios e para sua equipe.'),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Clínica',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business_rounded),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  enabled: isAdmin,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  enabled: isAdmin,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  enabled: isAdmin,
                ),
                const SizedBox(height: 32),
                if (isAdmin)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VittaOnlineTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  const Card(
                    color: Colors.amberAccent,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline),
                          SizedBox(width: 12),
                          Expanded(child: Text('Apenas administradores podem editar estas informações.')),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (kDebugMode) {
          debugPrint('Clinic settings tab data error: $e');
        }
        return const Center(child: Text('Não foi possível completar a ação. Tente novamente.'));
      },
    );
  }
}

class StaffManagementTab extends ConsumerWidget {
  const StaffManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final isAdmin = profileAsync.value?.role == UserRole.admin;

    return staffAsync.when(
      data: (staff) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: staff.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final person = staff[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: VittaOnlineTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(person.fullName[0].toUpperCase(), style: const TextStyle(color: VittaOnlineTheme.primaryColor)),
              ),
              title: Text(person.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(person.role.name.toUpperCase()),
              trailing: isAdmin && person.id != profileAsync.value?.id
                  ? PopupMenuButton<UserRole>(
                      onSelected: (value) async {
                        final updated = person.copyWith(role: value);
                        await ref.read(profileServiceProvider).updateProfile(updated);
                        ref.invalidate(staffProvider);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: UserRole.admin, child: Text('Promover a Admin')),
                        const PopupMenuItem(value: UserRole.auxiliar, child: Text('Tornar Auxiliar')),
                      ],
                    )
                  : null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (kDebugMode) {
          debugPrint('Staff management tab data error: $e');
        }
        return const Center(child: Text('Não foi possível completar a ação. Tente novamente.'));
      },
    );
  }
}

class UserProfileTab extends ConsumerStatefulWidget {
  const UserProfileTab({super.key});

  @override
  ConsumerState<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends ConsumerState<UserProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;

    setState(() => _isLoading = true);
    try {
      // 1. Update Profile name (Database)
      if (_nameController.text != profile.fullName) {
        await ref.read(profileServiceProvider).updateProfile(
          profile.copyWith(fullName: _nameController.text),
        );
      }

      // 2. Update Auth (Email/Password) - Supabase Auth API
      String? newEmail = _emailController.text != ref.read(userProvider)?.email ? _emailController.text : null;
      String? newPassword = _passwordController.text.isNotEmpty ? _passwordController.text : null;

      if (newEmail != null || newPassword != null) {
        await ref.read(authServiceProvider).updateAuthUser(
          email: newEmail,
          password: newPassword,
        );
      }

      ref.invalidate(currentProfileProvider);
      ref.invalidate(userProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        _passwordController.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating profile: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível completar a ação. Tente novamente.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final user = ref.watch(userProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const Center(child: Text('Perfil não encontrado.'));

        if (_nameController.text.isEmpty) {
          _nameController.text = profile.fullName;
          _emailController.text = user?.email ?? '';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Segurança e Preferências',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VittaOnlineTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Seu Nome Completo', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email de Acesso', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha (deixe em branco para manter)',
                    border: OutlineInputBorder(),
                    helperText: 'Mínimo de 6 caracteres.',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VittaOnlineTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Atualizar Meu Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        if (kDebugMode) {
          debugPrint('User profile tab data error: $e');
        }
        return const Center(child: Text('Não foi possível completar a ação. Tente novamente.'));
      },
    );
  }
}

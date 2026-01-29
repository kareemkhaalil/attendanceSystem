import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/di/injection_container.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart' as sp;

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../clients/presentation/cubit/client_cubit.dart';
import '../../../clients/presentation/cubit/client_state.dart';
import '../../domain/entities/user_entity.dart' as app_user;
import '../cubit/user_cubit.dart';

class UsersCreateScreen extends StatefulWidget {
  const UsersCreateScreen({super.key});

  @override
  State<UsersCreateScreen> createState() => _UsersCreateScreenState();
}

class _UsersCreateScreenState extends State<UsersCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.employee;
  ClientEntity? _selectedClient;
  bool _isSuperAdmin = false;
  bool _isLimitReached = false;

  late final UserCubit _userCubit;
  late final ClientCubit _clientCubit;

  List<UserRole> get _roles {
    if (_isSuperAdmin) {
      return [UserRole.superAdmin, UserRole.cad, UserRole.employee];
    }
    return [UserRole.cad, UserRole.employee];
  }

  @override
  void initState() {
    super.initState();
    _userCubit = getIt<UserCubit>();
    _clientCubit = getIt<ClientCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  void _loadCurrentUser() {
    final user = sp.SharedPrefHelper.getUser();
    if (user != null) {
      if (mounted) {
        setState(() {
          _isSuperAdmin = user.role == UserRole.superAdmin;
        });
      }
      print('Current user role: ${user.role}, isSuperAdmin: $_isSuperAdmin');

      if (_isSuperAdmin) {
        _clientCubit.getClients();
      } else {
        final clientForUser = ClientEntity(
          id: user.tenantId,
          name: "My Company",
          allowedUsers: 5,
          currentUsers: 2,
          plan: "Free",
          subscriptionStart: DateTime.now(),
          subscriptionEnd: DateTime.now().add(const Duration(days: 30)),
          billingAmount: 0,
          billingInterval: "monthly",
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          allowedBranches: 1,
          currentBranches: 1,
        );
        if (mounted) {
          setState(() {
            _selectedClient = clientForUser;
            _updateClientLimits(_selectedClient);
          });
        }
      }
    } else {
      print('No current user found');
    }
  }

  void _updateClientLimits(ClientEntity? client) {
    if (client == null) {
      if (mounted) setState(() => _isLimitReached = false);
      return;
    }
    final allowed = client.allowedUsers;
    final current = client.currentUsers;
    final remaining = (current != null) ? (allowed - current) : 1;

    if (mounted) setState(() => _isLimitReached = remaining <= 0);
  }

  @override
  void dispose() {
    _userCubit.close();
    _clientCubit.close();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _userCubit),
        BlocProvider.value(value: _clientCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New User'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/users'),
          ),
        ),
        body: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('✅ User "${_nameCtrl.text}" created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/users');
            } else if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is UserLoading;
            return Stack(
              children: [
                _buildForm(context, isLoading),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_add,
                                size: 32,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create New User',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Add a new user to the system',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        buildClientSelection(),
                        const SizedBox(height: 16),
                        _buildClientLimitsStrip(),
                        const SizedBox(height: 16),
                        _buildLimitWarning(),
                        const SizedBox(height: 24),
                        _buildUserFields(isDisabled: _isLimitReached),
                        const SizedBox(height: 32),
                        buildActionButtons(context, isLoading, _isLimitReached),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildClientSelection() {
    final isEnabled = _isSuperAdmin;
    if (_isSuperAdmin) {
      return BlocConsumer<ClientCubit, ClientState>(
        listener: (context, state) {
          if (state is ClientsLoaded &&
              _selectedClient == null &&
              state.clients.isNotEmpty) {
            setState(() {
              _selectedClient = state.clients.first;
              _updateClientLimits(_selectedClient);
            });
          }
        },
        builder: (context, state) {
          if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClientsLoaded) {
            return buildClientDropdown(state.clients, _selectedClient,
                isEnabled: isEnabled);
          }
          if (state is ClientError) {
            return const Text('Error loading clients');
          }
          return Container();
        },
      );
    } else {
      if (_selectedClient != null) {
        return buildClientDropdown([_selectedClient!], _selectedClient,
            isEnabled: false);
      }
      return Container();
    }
  }

  Widget buildClientDropdown(List<ClientEntity> clients, ClientEntity? initial,
      {required bool isEnabled}) {
    print(
        'Dropdown built with ${clients.length} clients, selected: ${initial?.name}, enabled: $isEnabled');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Client',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: !isEnabled,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: DropdownButtonFormField<ClientEntity>(
              value: initial,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: const OutlineInputBorder(),
                hintText: 'Choose a client',
                filled: !isEnabled,
                fillColor: isEnabled ? null : Colors.grey.shade200,
              ),
              items: clients
                  .map((client) => DropdownMenuItem<ClientEntity>(
                        value: client,
                        child: Text(client.name),
                      ))
                  .toList(),
              onChanged: isEnabled
                  ? (ClientEntity? newValue) {
                      setState(() => _selectedClient = newValue);
                      _updateClientLimits(newValue);
                      print('Client changed to: ${newValue?.name}');
                    }
                  : null,
              validator: isEnabled
                  ? (value) => value == null ? 'Please select a client' : null
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserFields({required bool isDisabled}) {
    return AbsorbPointer(
      absorbing: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          children: [
            CustomInput(
              controller: _nameCtrl,
              label: 'Full Name',
              hintText: 'Enter user full name',
              prefixIcon: Icons.person,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: _emailCtrl,
              label: 'Email Address',
              hintText: 'Enter user email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                final ok =
                    RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v);
                if (!ok) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: _passwordCtrl,
              label: 'Password',
              hintText: 'Enter a strong password',
              prefixIcon: Icons.lock,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomInput(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hintText: 'Enter user phone number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole?>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.security),
                border: OutlineInputBorder(),
              ),
              items: _roles
                  .map((role) => DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(_getRoleDisplay(role)),
                      ))
                  .toList(),
              onChanged: (UserRole? newValue) {
                if (newValue != null) {
                  setState(() => _selectedRole = newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplay(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'مدير عام';
      case UserRole.cad:
        return 'مدير ';
      case UserRole.branchManager:
        return 'مدير فرع';
      case UserRole.employee:
        return 'موظف';
    }
  }

  Widget buildActionButtons(
      BuildContext context, bool isLoading, bool isDisabled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isLoading ? null : () => context.go('/users'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        CustomButton(
          text: 'Create User',
          onPressed: isLoading || isDisabled ? null : _onSavePressed,
          isLoading: isLoading,
          icon: Icons.add,
        ),
      ],
    );
  }

  void _onSavePressed() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_isSuperAdmin && _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client before saving.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = app_user.UserEntity(
      id: '',
      tenantId: _selectedClient!.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _selectedRole,
      password: _passwordCtrl.text,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _userCubit.createUser(user);
  }

  Widget _buildClientLimitsStrip() {
    final allowed = _selectedClient?.allowedUsers;
    final current = _selectedClient?.currentUsers;
    final remaining =
        (allowed != null && current != null) ? (allowed - current) : null;

    return Row(
      children: [
        _miniInfoCard(
            title: 'Allowed users',
            value: allowed?.toString() ?? '--',
            icon: Icons.verified_user),
        const SizedBox(width: 12),
        _miniInfoCard(
          title: 'Remaining',
          value: remaining?.toString() ?? '--',
          icon: Icons.person_add_alt_1,
          valueColor:
              (remaining != null && remaining <= 0) ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildLimitWarning() {
    if (!_isLimitReached) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'User limit reached. All fields are disabled.',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

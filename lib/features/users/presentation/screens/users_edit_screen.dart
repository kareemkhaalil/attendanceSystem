import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class UsersEditScreen extends StatefulWidget {
  final app_user.UserEntity editingUser;

  const UsersEditScreen({super.key, required this.editingUser});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.employee;
  ClientEntity? _selectedClient;
  bool _isSuperAdmin = false;
  String? _tenantId;

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
    _loadUserData(widget.editingUser);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  void _loadUserData(app_user.UserEntity user) {
    _nameCtrl.text = user.name ?? '';
    _emailCtrl.text = user.email ?? '';
    _phoneCtrl.text = user.phone ?? '';
    _selectedRole = user.role ?? UserRole.employee;
    _tenantId = user.tenantId;

    if (mounted) setState(() {});
  }

  void _loadCurrentUser() {
    final currentUser = sp.SharedPrefHelper.getUser();
    if (currentUser != null) {
      if (mounted) {
        setState(() {
          _isSuperAdmin = currentUser.role == UserRole.superAdmin;
        });
      }

      if (_isSuperAdmin) {
        // لو سوبر أدمن: هجيب كل العملاء وأحدد العميل بتاع المستخدم
        _clientCubit.getClients();
      } else {
        // لو مش سوبر أدمن: أجيب العميل من السيرفر باستخدام tenantId
        _clientCubit.getClientById(widget.editingUser.tenantId);
      }
    }
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
          title: const Text('تعديل مستخدم'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/users'),
          ),
        ),
        body: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('✅ تم تعديل المستخدم "${_nameCtrl.text}" بنجاح'),
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
                            Icon(Icons.edit,
                                size: 32,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit User',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Modify user details in the system',
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
                        buildClientField(),
                        const SizedBox(height: 16),
                        _buildUserFields(),
                        const SizedBox(height: 32),
                        buildActionButtons(context, isLoading),
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

  /// 👇 هنا بقى عندنا حالتين:
  /// - سوبر أدمن: Dropdown لاختيار العميل
  /// - غير سوبر أدمن: TextFormField readOnly باسم العميل
  Widget buildClientField() {
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) {
        if (_isSuperAdmin) {
          if (state is ClientsLoaded) {
            final clients = state.clients;

            // 1. التعامل مع حالة عدم وجود عملاء أولاً
            if (clients.isEmpty) {
              return TextFormField(
                decoration: const InputDecoration(
                  labelText: 'العميل',
                  border: OutlineInputBorder(),
                  hintText: 'لا يوجد عملاء متاحين',
                  prefixIcon: Icon(Icons.business),
                ),
                enabled: false,
              );
            }

            // 2. تحديد القيمة الافتراضية بأمان الآن بعد التأكد أن القائمة ليست فارغة
            ClientEntity initialSelection;
            try {
              // محاولة العثور على العميل الحالي للمستخدم
              initialSelection = clients.firstWhere((c) => c.id == _tenantId);
            } catch (e) {
              // إذا لم يتم العثور عليه، يتم اختيار أول عميل في القائمة كقيمة افتراضية
              initialSelection = clients.first;
            }

            // 3. بناء الـ Dropdown بالقيمة الآمنة
            return DropdownButtonFormField<ClientEntity>(
              value: _selectedClient ??
                  initialSelection, // استخدام القيمة المختارة من المستخدم أو القيمة الافتراضية
              decoration: const InputDecoration(
                labelText: 'اختر العميل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: clients
                  .map((client) => DropdownMenuItem<ClientEntity>(
                        value: client,
                        child: Text(client.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedClient = value);
                }
              },
              validator: (value) => value == null ? 'يجب اختيار العميل' : null,
            );
          } else if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Text('⚠️ لا توجد بيانات عملاء');
          }
        } else {
          if (state is ClientLoaded) {
            _selectedClient = state.client;
            return TextFormField(
              initialValue: state.client.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                labelText: 'العميل',
                filled: true,
              ),
              readOnly: true,
            );
          } else if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Text('⚠️ لم يتم العثور على عميل لهذا المستخدم');
          }
        }
      },
    );
  }

  Widget _buildUserFields() {
    return Column(
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
            final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v);
            if (!ok) return 'Please enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomInput(
          controller: _passwordCtrl,
          label: 'New Password (Optional)',
          hintText: 'Leave empty to keep current',
          prefixIcon: Icons.lock,
          isPassword: true,
          validator: (v) => v != null && v.isNotEmpty && v.length < 6
              ? 'Password must be at least 6 characters'
              : null,
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
          value: _roles.contains(_selectedRole) ? _selectedRole : null,
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

  Widget buildActionButtons(BuildContext context, bool isLoading) {
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
          text: 'Update User',
          onPressed: isLoading ? null : _onSavePressed,
          isLoading: isLoading,
          icon: Icons.save,
        ),
      ],
    );
  }

  void _onSavePressed() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client information is missing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedPassword =
        _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null;

    final user = app_user.UserEntity(
      id: widget.editingUser.id,
      tenantId: _selectedClient!.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _selectedRole,
      password: updatedPassword,
      isActive: widget.editingUser.isActive,
      createdAt: widget.editingUser.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _userCubit.updateUser(user);
  }
}

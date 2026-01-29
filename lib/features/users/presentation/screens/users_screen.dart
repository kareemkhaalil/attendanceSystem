import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/features/clients/domain/entities/client_entity.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_cubit.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_state.dart';
import 'package:manzoma/features/users/presentation/screens/users_create_screen.dart';
import 'package:manzoma/features/users/presentation/screens/users_edit_screen.dart';
import '../cubit/user_cubit.dart';
export 'package:manzoma/core/entities/user_entity.dart';
import '../widgets/add_user_dialog.dart';
import '../widgets/user_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  UserRole? selectedRole;
  String? selectedClientId; // ✅ للفلترة بالعميل
  String searchQuery = '';
  List<ClientEntity> clients = [];

  @override
  void initState() {
    super.initState();
    // نجيب العملاء أولاً
    context.read<ClientCubit>().getClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إدارة المستخدمين',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'إضافة مستخدم جديد',
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ClientCubit, ClientState>(
            listener: (context, state) {
              if (state is ClientsLoaded) {
                setState(() {
                  clients = state.clients;
                });

                // 👈 أول ما العملاء يتحملوا نجيب المستخدمين
                context.read<UserCubit>().getUsers(
                      role: selectedRole,
                      tenantId: selectedClientId,
                    );
              }
            },
          ),
          BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف المستخدم بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the users list
                context.read<UserCubit>().getUsers(
                      role: selectedRole,
                      tenantId: selectedClientId,
                    );
              }
            },
          ),
        ],
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: EdgeInsets.all(16.w),
              color: Colors.white,
              child: Column(
                children: [
                  // Clients Dropdown
                  DropdownButtonFormField<String?>(
                    value: selectedClientId,
                    hint: const Text('الرجاء اختيار عميل'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('جميع العملاء'),
                      ),
                      ...clients.map(
                        (client) => DropdownMenuItem<String?>(
                          value: client.id,
                          child: Text(client.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedClientId = value;
                      });
                      context.read<UserCubit>().getUsers(
                            role: selectedRole,
                            tenantId: value,
                          );
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Search Bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'البحث عن مستخدم...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Role Filter
                  Row(
                    children: [
                      Text(
                        'تصفية حسب الدور:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: DropdownButtonFormField<UserRole?>(
                          value: selectedRole,
                          hint: const Text('جميع الأدوار'),
                          items: const [
                            DropdownMenuItem<UserRole?>(
                              value: null,
                              child: Text('جميع الأدوار'),
                            ),
                            DropdownMenuItem<UserRole?>(
                              value: UserRole.superAdmin,
                              child: Text('مدير عام'),
                            ),
                            DropdownMenuItem<UserRole?>(
                              value: UserRole.cad,
                              child: Text('مدير فرع'),
                            ),
                            DropdownMenuItem<UserRole?>(
                              value: UserRole.employee,
                              child: Text('موظف'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                            });
                            context.read<UserCubit>().getUsers(
                                  role: value,
                                  tenantId: selectedClientId,
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Users List
            Expanded(
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is UserError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.w,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'حدث خطأ: ${state.message}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<UserCubit>().getUsers(
                                    role: selectedRole,
                                    tenantId: selectedClientId,
                                  );
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is UserLoaded) {
                    final filteredUsers = state.users.where((user) {
                      final matchesSearch = searchQuery.isEmpty ||
                          user.name
                                  ?.toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ==
                              true ||
                          user.email
                                  ?.toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ==
                              true;
                      return matchesSearch;
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64.w,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد مستخدمين',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'اضغط على + لإضافة مستخدم جديد',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<UserCubit>().getUsers(
                              role: selectedRole,
                              tenantId: selectedClientId,
                            );
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return UserCard(
                            user: filteredUsers[index],
                            onTap: () => _showUserDetails(
                              context,
                              filteredUsers[index],
                            ),
                            onEdit: () {
                              // يفتح شاشة التعديل
                              context.push(
                                '/users/edit',
                                extra: UsersEditScreen(
                                  editingUser: filteredUsers[index],
                                ),
                              );
                            },
                            onDelete: () => _showDeleteConfirmation(
                              context,
                              filteredUsers[index],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.displayName}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<UserCubit>().deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('البريد الإلكتروني', user.email ?? 'غير محدد'),
            _buildDetailRow('الهاتف', user.phone ?? 'غير محدد'),
            _buildDetailRow('الدور', _getRoleDisplayName(user.role)),
            _buildDetailRow('الراتب الأساسي', '${user.baseSalary} ج.م'),
            _buildDetailRow('الحالة', user.isActive ? 'نشط' : 'غير نشط'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
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
}

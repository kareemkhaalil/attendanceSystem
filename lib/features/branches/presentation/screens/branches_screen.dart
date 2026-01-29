import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_state.dart';
import '../cubit/branch_cubit.dart';
import '../../domain/entities/branch_entity.dart';
import '../widgets/branch_card.dart';
import '../../../clients/presentation/cubit/client_cubit.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  String searchQuery = '';
  String? selectedClientId;

  @override
  void initState() {
    super.initState();
    // تحميل الفروع والعملاء
    context.read<BranchCubit>().getBranches();
    context.read<ClientCubit>().getClients();
  }

  void _onClientChanged(String? clientId) {
    setState(() {
      selectedClientId = clientId;
    });
    context.read<BranchCubit>().getBranches(clientId: clientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إدارة الفروع',
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
            onPressed: () => context.push('/branches/create'),
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'إضافة فرع جديد',
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Column(
        children: [
          // اختيار العميل
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: BlocBuilder<ClientCubit, ClientState>(
              builder: (context, state) {
                if (state is ClientLoading) {
                  return const LinearProgressIndicator();
                } else if (state is ClientsLoaded) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "اختر العميل",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    value: selectedClientId,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("بالرجاء اختيار عميل"),
                      ),
                      ...state.clients.map(
                        (client) => DropdownMenuItem<String>(
                          value: client.id,
                          child: Text(client.name),
                        ),
                      ),
                    ],
                    onChanged: _onClientChanged,
                  );
                } else if (state is ClientError) {
                  return Text("خطأ في تحميل العملاء: ${state.message}");
                }
                return const SizedBox();
              },
            ),
          ),

          // مربع البحث
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'البحث عن فرع...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // عرض الفروع
          Expanded(
            child: BlocBuilder<BranchCubit, BranchState>(
              builder: (context, state) {
                if (state is BranchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BranchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64.w, color: Colors.red),
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
                            context
                                .read<BranchCubit>()
                                .getBranches(clientId: selectedClientId);
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                } else if (state is BranchLoaded) {
                  final filteredBranches = state.branches.where((branch) {
                    final matchesSearch = searchQuery.isEmpty ||
                        branch.name
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        (branch.address
                                ?.toLowerCase()
                                .contains(searchQuery.toLowerCase()) ??
                            false);
                    return matchesSearch;
                  }).toList();

                  if (filteredBranches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store_outlined,
                              size: 64.w, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد فروع',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'اضغط على + لإضافة فرع جديد',
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
                      context
                          .read<BranchCubit>()
                          .getBranches(clientId: selectedClientId);
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filteredBranches.length,
                      itemBuilder: (context, index) {
                        final branch = filteredBranches[index];

                        return BranchCard(
                          branch: branch,
                          onTap: () => _showBranchDetails(context, branch),
                          // --- إضافة الـ trailing widget هنا ---
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                // --- التوجيه لصفحة التعديل مع تمرير بيانات الفرع ---
                                context.push('/branches/edit', extra: branch);
                              } else if (value == 'delete') {
                                // يمكنك إضافة منطق الحذف هنا لاحقًا
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('تعديل'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('حذف',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
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
    );
  }

  void _showBranchDetails(BuildContext context, BranchEntity branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(branch.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('العنوان', branch.fullAddress),
            _buildDetailRow('خط العرض', branch.latitude.toStringAsFixed(6)),
            _buildDetailRow('خط الطول', branch.longitude.toStringAsFixed(6)),
            _buildDetailRow(
                'نطاق الحضور', '${branch.radiusMeters.toStringAsFixed(0)} متر'),
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
}

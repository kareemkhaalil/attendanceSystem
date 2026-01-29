import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import '../cubit/payroll_cubit.dart';
import '../cubit/payroll_state.dart';

class EmployeePayrollPage extends StatefulWidget {
  const EmployeePayrollPage({super.key});

  @override
  State<EmployeePayrollPage> createState() => _EmployeePayrollPageState();
}

class _EmployeePayrollPageState extends State<EmployeePayrollPage> {
  String? selectedTenantId;
  List<UserEntity> selectedEmployees = [];
  final user = SharedPrefHelper.getUser();

  @override
  void initState() {
    selectedTenantId = user?.tenantId;
    super.initState();
    context.read<PayrollCubit>().fetchClients(); // تجيب قائمة العملاء
    context
        .read<PayrollCubit>()
        .fetchEmployees(selectedTenantId!); // تجيب الموظفين
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة مرتبات الموظفين"),
        centerTitle: true,
      ),
      body: BlocBuilder<PayrollCubit, PayrollState>(
        builder: (context, state) {
          if (state.status == PayrollStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // final tenants = state.clients; // قائمة العملاء
          final employees = state.employees; // الموظفين حسب العميل

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: employees.isEmpty
                      ? const Center(child: Text("اختر عميل لعرض موظفيه"))
                      : ListView(
                          children: employees.map((emp) {
                            final isSelected =
                                selectedEmployees.any((e) => e.id == emp.id);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: CheckboxListTile(
                                value: isSelected,
                                title: Text(emp.name!),
                                subtitle: Text(
                                    "الراتب الأساسي: ${emp.baseSalary.toStringAsFixed(2)} EGP"),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedEmployees.add(emp);
                                    } else {
                                      selectedEmployees
                                          .removeWhere((e) => e.id == emp.id);
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text("عرض كشف المرتبات"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed:
                      selectedEmployees.isEmpty || selectedTenantId == null
                          ? null
                          : () {
                              GoRouter.of(context).push(
                                '/payroll/employees/salary',
                                extra: {
                                  "tenantId": selectedTenantId!,
                                  "employees": selectedEmployees,
                                },
                              );
                            },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

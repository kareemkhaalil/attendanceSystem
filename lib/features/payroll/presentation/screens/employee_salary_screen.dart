import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import '../cubit/payroll_cubit.dart';
import '../cubit/payroll_state.dart';
import '../../domain/entities/payroll_rules_entity.dart';
import '../../domain/entities/payroll_detail_entity.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';

class EmployeeSalaryScreen extends StatefulWidget {
  final String tenantId;
  final List<UserEntity> employees;

  const EmployeeSalaryScreen({
    super.key,
    required this.tenantId,
    required this.employees,
  });

  @override
  State<EmployeeSalaryScreen> createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  // بدل ما كانت قاعدة واحدة لكل موظف، دلوقتي List من القواعد
  final Map<String, List<PayrollRuleEntity?>> selectedRules = {};

  @override
  void initState() {
    super.initState();
    context.read<PayrollCubit>().fetchRules(widget.tenantId);

    // تهيئة: لكل موظف يبقى عنده Dropdown واحد فاضي
    for (var emp in widget.employees) {
      selectedRules[emp.id] = [null];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayrollCubit, PayrollState>(
      builder: (context, state) {
        if (state.status == PayrollStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final rules = state.rules;

        return Scaffold(
          appBar: AppBar(
            title: const Text("كشف المرتبات"),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...widget.employees.map((emp) {
                final additions = state.details
                    .where(
                        (d) => d.payrollId == emp.id && d.type == 'allowance')
                    .fold(0.0, (sum, d) => sum + d.amount);

                final deductions = state.details
                    .where(
                        (d) => d.payrollId == emp.id && d.type == 'deduction')
                    .fold(0.0, (sum, d) => sum + d.amount);

                final net = emp.baseSalary + additions - deductions;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.name ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _row("الراتب الأساسي",
                            emp.baseSalary.toStringAsFixed(2)),
                        _row("الإضافات", additions.toStringAsFixed(2),
                            color: Colors.green),
                        _row("الخصومات", deductions.toStringAsFixed(2),
                            color: Colors.red),
                        const Divider(),
                        _row("الصافي", net.toStringAsFixed(2), bold: true),
                        const SizedBox(height: 12),

                        // القواعد المطبقة على الموظف
                        ...state.details
                            .where((d) => d.payrollId == emp.id)
                            .map((d) => ListTile(
                                  leading: Icon(
                                    d.type == 'allowance'
                                        ? Icons.add_circle
                                        : Icons.remove_circle,
                                    color: d.type == 'allowance'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(d.ruleName),
                                  subtitle: Text(
                                      "${d.amount.toStringAsFixed(2)} EGP (${d.type})"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      context
                                          .read<PayrollCubit>()
                                          .removeDetail(d.id);
                                    },
                                  ),
                                )),

                        const Divider(),

                        // Dropdowns لاختيار قواعد متعددة
                        ...List.generate(selectedRules[emp.id]!.length, (i) {
                          return Column(
                            children: [
                              DropdownButtonFormField<PayrollRuleEntity>(
                                value: selectedRules[emp.id]![i],
                                hint: const Text("اختر قاعدة"),
                                items: rules
                                    .map((r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r.name),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedRules[emp.id]![i] = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),

                        // زرار لإضافة Dropdown جديد
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedRules[emp.id]!.add(null);
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("إضافة قاعدة أخرى"),
                        ),

                        const SizedBox(height: 8),

                        // زرار لتطبيق القواعد
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("تطبيق القواعد"),
                          onPressed: () {
                            for (var rule in selectedRules[emp.id]!) {
                              if (rule != null) {
                                final detail = PayrollDetailEntity(
                                  tenantId: widget.tenantId,
                                  id: DateTime.now()
                                      .microsecondsSinceEpoch
                                      .toString(),
                                  payrollId: emp.id,
                                  ruleName: rule.name,
                                  type: rule.type,
                                  calculationMethod: rule.calculationMethod,
                                  amount:
                                      _calculateAmount(rule, emp.baseSalary),
                                  createdAt: DateTime.now(),
                                );
                                context.read<PayrollCubit>().addDetail(detail);
                              }
                            }
                            // reset بعد التطبيق
                            setState(() {
                              selectedRules[emp.id] = [null];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String title, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            "$value EGP",
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAmount(PayrollRuleEntity rule, double basicSalary) {
    switch (rule.calculationMethod) {
      case "fixed":
        return rule.value;
      case "percentage":
        return (basicSalary * rule.value / 100);
      default:
        return 0;
    }
  }
}

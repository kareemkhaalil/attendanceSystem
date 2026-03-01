import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import 'package:manzoma/core/widgets/custom_text_field.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_state.dart';
import '../cubit/payroll_cubit.dart';
import '../cubit/payroll_state.dart';
import '../../domain/entities/employee_salary_profile_entity.dart';
import '../../domain/entities/payroll_rules_entity.dart';

class EmployeeSalaryProfileScreen extends StatefulWidget {
  final UserEntity employee;
  const EmployeeSalaryProfileScreen({super.key, required this.employee});

  @override
  State<EmployeeSalaryProfileScreen> createState() => _EmployeeSalaryProfileScreenState();
}

class _EmployeeSalaryProfileScreenState extends State<EmployeeSalaryProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _basicSalaryController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ibanController;
  String _paymentMethod = 'bank_transfer';
  List<String> _selectedRuleIds = [];

  @override
  void initState() {
    super.initState();
    _basicSalaryController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ibanController = TextEditingController();

    final payrollCubit = context.read<PayrollCubit>();
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    
    payrollCubit.fetchRules(authState.user.tenantId);
    payrollCubit.fetchEmployeeProfile(widget.employee.id);
  }

  @override
  void dispose() {
    _basicSalaryController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  void _initFields(EmployeeSalaryProfileEntity? profile, List<String> ruleIds) {
    if (profile != null) {
      _basicSalaryController.text = profile.basicSalary.toString();
      _bankNameController.text = profile.bankName ?? '';
      _accountNumberController.text = profile.accountNumber ?? '';
      _ibanController.text = profile.iban ?? '';
      _paymentMethod = profile.paymentMethod;
      _selectedRuleIds = List.from(ruleIds);
    } else {
      _basicSalaryController.text = '0.0';
      _paymentMethod = 'bank_transfer';
      _selectedRuleIds = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PayrollCubit, PayrollState>(
      listenWhen: (p, c) => p.status != c.status || p.message != c.message,
      listener: (context, state) {
        if (state.status == PayrollStatus.success && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!), backgroundColor: Colors.green),
          );
        }
        if (state.status == PayrollStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('ملف راتب: ${widget.employee.name}'),
          actions: [
            IconButton(
              onPressed: _save,
              icon: const Icon(Icons.save),
            ),
          ],
        ),
        body: BlocBuilder<PayrollCubit, PayrollState>(
          builder: (context, state) {
            if (state.status == PayrollStatus.loading && state.salaryProfile == null && state.rules.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            _initFields(state.salaryProfile, state.selectedRuleIds);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('الراتب والتحويل'),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _basicSalaryController,
                      label: 'الراتب الأساسي',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.money),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: InputDecoration(
                        labelText: 'طريقة الدفع',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'bank_transfer', child: Text('تحويل بنكي')),
                        DropdownMenuItem(value: 'cash', child: Text('كاش')),
                        DropdownMenuItem(value: 'wallet', child: Text('محفظة إلكترونية')),
                      ],
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                    if (_paymentMethod == 'bank_transfer') ...[
                      const SizedBox(height: 16),
                      CustomTextField(controller: _bankNameController, label: 'اسم البنك'),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _accountNumberController, label: 'رقم الحساب'),
                      const SizedBox(height: 16),
                      CustomTextField(controller: _ibanController, label: 'IBAN'),
                    ],
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('البنود والبدلات الإضافية'),
                    const SizedBox(height: 8),
                    const Text('اختر القواعد المالية التي تنطبق على هذا الموظف تلقائيًا.'),
                    const SizedBox(height: 16),
                    
                    ...state.rules.map((rule) {
                      final isSelected = _selectedRuleIds.contains(rule.id);
                      return CheckboxListTile(
                        title: Text(rule.name),
                        subtitle: Text('${rule.type == 'allowance' ? '+' : '-'} ${rule.value} (${rule.calculationMethod})'),
                        secondary: Icon(
                          rule.type == 'allowance' ? Icons.add_circle_outline : Icons.remove_circle_outline,
                          color: rule.type == 'allowance' ? Colors.green : Colors.red,
                        ),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedRuleIds.add(rule.id);
                            } else {
                              _selectedRuleIds.remove(rule.id);
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('حفظ ملف الراتب'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state as AuthAuthenticated;
      final currentProfile = context.read<PayrollCubit>().state.salaryProfile;
      
      final profile = EmployeeSalaryProfileEntity(
        id: currentProfile?.id ?? '', 
        userId: widget.employee.id,
        tenantId: authState.user.tenantId,
        basicSalary: double.tryParse(_basicSalaryController.text) ?? 0.0,
        paymentMethod: _paymentMethod,
        bankName: _bankNameController.text.isNotEmpty ? _bankNameController.text : null,
        accountNumber: _accountNumberController.text.isNotEmpty ? _accountNumberController.text : null,
        iban: _ibanController.text.isNotEmpty ? _ibanController.text : null,
        createdAt: currentProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      context.read<PayrollCubit>().saveEmployeeProfile(profile, _selectedRuleIds);
    }
  }
}

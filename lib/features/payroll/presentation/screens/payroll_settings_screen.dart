import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/widgets/custom_text_field.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_state.dart';
import '../cubit/payroll_cubit.dart';
import '../cubit/payroll_state.dart';
import '../../domain/entities/payroll_regulation_entity.dart';

class PayrollSettingsScreen extends StatefulWidget {
  const PayrollSettingsScreen({super.key});

  @override
  State<PayrollSettingsScreen> createState() => _PayrollSettingsScreenState();
}

class _PayrollSettingsScreenState extends State<PayrollSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _hoursController;
  late TextEditingController _daysController;
  late TextEditingController _overtimeController;
  late TextEditingController _lateController;
  String _currency = 'EGP';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hoursController = TextEditingController();
    _daysController = TextEditingController();
    _overtimeController = TextEditingController();
    _lateController = TextEditingController();

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<PayrollCubit>().fetchRegulation(authState.user.tenantId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    _daysController.dispose();
    _overtimeController.dispose();
    _lateController.dispose();
    super.dispose();
  }

  void _initFields(PayrollRegulationEntity? reg) {
    if (reg != null) {
      _nameController.text = reg.name;
      _hoursController.text = reg.workingHoursPerDay.toString();
      _daysController.text = reg.workingDaysPerMonth.toString();
      _overtimeController.text = reg.overtimeRate.toString();
      _lateController.text = reg.lateDeductionRate.toString();
      _currency = reg.baseCurrency;
    } else {
      _nameController.text = 'اللائحة الافتراضية';
      _hoursController.text = '8';
      _daysController.text = '26';
      _overtimeController.text = '1.5';
      _lateController.text = '1.0';
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
          title: const Text('إعدادات اللوائح المالية'),
          actions: [
            IconButton(
              onPressed: _save,
              icon: const Icon(Icons.save),
              tooltip: 'حفظ التغييرات',
            ),
          ],
        ),
        body: BlocBuilder<PayrollCubit, PayrollState>(
          builder: (context, state) {
            if (state.status == PayrollStatus.loading && state.regulation == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.regulation != null) {
              _initFields(state.regulation);
            } else if (state.status == PayrollStatus.success && state.regulation == null) {
               _initFields(null);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اللوائح والسياسات العامة',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('قم بتعيين القواعد الأساسية لحساب الرواتب لهذا التينانت.'),
                    const Divider(height: 32),
                    
                    CustomTextField(
                      controller: _nameController,
                      label: 'اسم اللائحة',
                      hint: 'مثال: لائحة الموظفين الدائمين',
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _hoursController,
                            label: 'ساعات العمل / يوم',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _daysController,
                            label: 'أيام العمل / شهر',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _overtimeController,
                            label: 'معدل الإضافي (ساعة = س * X)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _lateController,
                            label: 'معدل خصم التأخير',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('العملة الأساسية', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: ['EGP', 'USD', 'SAR', 'AED', 'KWD'].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: state.status == PayrollStatus.loading ? null : _save,
                        icon: state.status == PayrollStatus.loading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle),
                        label: const Text('حفظ إعدادات اللائحة'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state as AuthAuthenticated;
      final currentReg = context.read<PayrollCubit>().state.regulation;
      
      final regulation = PayrollRegulationEntity(
        id: currentReg?.id ?? '', // Upsert will handle empty ID
        tenantId: authState.user.tenantId,
        name: _nameController.text,
        workingHoursPerDay: double.tryParse(_hoursController.text) ?? 8.0,
        workingDaysPerMonth: double.tryParse(_daysController.text) ?? 26.0,
        overtimeRate: double.tryParse(_overtimeController.text) ?? 1.5,
        lateDeductionRate: double.tryParse(_lateController.text) ?? 1.0,
        baseCurrency: _currency,
        createdAt: currentReg?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      context.read<PayrollCubit>().saveRegulation(regulation);
    }
  }
}

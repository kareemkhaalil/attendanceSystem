import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import '../cubit/payroll_cubit.dart';
import '../cubit/payroll_state.dart';
import '../../domain/entities/payroll_rules_entity.dart';

class PayrollRulesScreen extends StatefulWidget {
  const PayrollRulesScreen({super.key});

  @override
  State<PayrollRulesScreen> createState() => _PayrollRulesScreenState();
}

class _PayrollRulesScreenState extends State<PayrollRulesScreen> {
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    final user = SharedPrefHelper.getUser();
    if (user != null) {
      context.read<PayrollCubit>().fetchRules(user.tenantId);
    }
  }

  void _showRuleFormDialog(BuildContext context, {PayrollRuleEntity? rule}) {
    final isEditing = rule != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: rule?.name ?? '');
    final valueController =
        TextEditingController(text: rule?.value.toString() ?? '');
    final descriptionController =
        TextEditingController(text: rule?.description ?? '');
    final formulaController =
        TextEditingController(text: rule?.customFormula ?? '');

    String selectedType = rule?.type ?? 'allowance';
    String selectedCalcMethod = rule?.calculationMethod ?? 'fixed';
    bool isAutomatic = rule?.isAutomatic ?? false;

    final user = SharedPrefHelper.getUser();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(isEditing ? 'تعديل القاعدة' : 'إضافة قاعدة جديدة'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'اسم القاعدة'),
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration:
                            const InputDecoration(labelText: 'نوع القاعدة'),
                        items: const [
                          DropdownMenuItem(
                              value: 'allowance', child: Text('إضافة')),
                          DropdownMenuItem(
                              value: 'deduction', child: Text('خصم')),
                        ],
                        onChanged: (v) =>
                            setStateInDialog(() => selectedType = v!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCalcMethod,
                        decoration:
                            const InputDecoration(labelText: 'طريقة الحساب'),
                        items: const [
                          DropdownMenuItem(
                              value: 'fixed', child: Text('مبلغ ثابت')),
                          DropdownMenuItem(
                              value: 'percentage', child: Text('نسبة مئوية')),
                          DropdownMenuItem(
                              value: 'per_hour', child: Text('لكل ساعة')),
                          DropdownMenuItem(
                              value: 'custom', child: Text('معادلة مخصصة')),
                        ],
                        onChanged: (v) =>
                            setStateInDialog(() => selectedCalcMethod = v!),
                      ),
                      const SizedBox(height: 16),
                      if (selectedCalcMethod != 'custom')
                        TextFormField(
                          controller: valueController,
                          decoration:
                              const InputDecoration(labelText: 'القيمة'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                      if (selectedCalcMethod == 'custom')
                        TextFormField(
                          controller: formulaController,
                          decoration: const InputDecoration(
                              labelText: 'المعادلة المخصصة'),
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'الوصف'),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('تطبيق تلقائي'),
                        value: isAutomatic,
                        onChanged: (v) =>
                            setStateInDialog(() => isAutomatic = v),
                        activeColor: successColor,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newRule = PayrollRuleEntity(
                        id: rule?.id ?? '', // id فاضي للإضافة
                        tenantId: user?.tenantId ?? "dummy-tenant",
                        name: nameController.text,
                        description: descriptionController.text,
                        type: selectedType,
                        calculationMethod: selectedCalcMethod,
                        value: selectedCalcMethod == 'custom'
                            ? 0
                            : double.parse(valueController.text),
                        isAutomatic: isAutomatic,
                        customFormula: selectedCalcMethod == 'custom'
                            ? formulaController.text
                            : null,
                        createdAt: rule?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      if (isEditing) {
                        context.read<PayrollCubit>().editRule(newRule);
                      } else {
                        context.read<PayrollCubit>().addRule(newRule);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child:
                      const Text('حفظ', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قواعد الرواتب'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/payroll/settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'إعدادات اللوائح',
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => GoRouter.of(context).go('/payroll'),
            tooltip: 'لوحة تحكم الرواتب',
          ),
        ],
      ),
      body: BlocBuilder<PayrollCubit, PayrollState>(
        builder: (context, state) {
          if (state.status == PayrollStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.rules.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.rules.length,
            itemBuilder: (context, index) {
              final rule = state.rules[index];
              return _buildRuleCard(context, rule);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRuleFormDialog(context),
        tooltip: 'إضافة قاعدة جديدة',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rule_folder_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('لا توجد قواعد بعد',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'أضف أول قاعدة للبدء في بناء نظام الرواتب',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إضافة قاعدة جديدة'),
            onPressed: () => _showRuleFormDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, PayrollRuleEntity rule) {
    final isAllowance = rule.type == 'allowance';
    final color = isAllowance ? successColor : errorColor;

    String valueString;
    switch (rule.calculationMethod) {
      case 'fixed':
        valueString = '${rule.value.toStringAsFixed(0)} EGP';
        break;
      case 'percentage':
        valueString = '${rule.value.toStringAsFixed(0)}%';
        break;
      case 'per_hour':
        valueString = '${rule.value.toStringAsFixed(0)} EGP/ساعة';
        break;
      case 'custom':
        valueString = rule.customFormula ?? 'معادلة مخصصة';
        break;
      default:
        valueString = rule.value.toString();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(rule.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        if (rule.isAutomatic)
                          const Chip(
                            label: Text('تلقائي'),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      valueString,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                    if (rule.description != null &&
                        rule.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(rule.description!,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: Theme.of(context).primaryColor),
                  onPressed: () => _showRuleFormDialog(context, rule: rule),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: errorColor),
                  onPressed: () {
                    context.read<PayrollCubit>().removeRule(rule.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:manzoma/features/payroll/domain/entities/payroll_rules_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PayrollRulesDataSource {
  final SupabaseClient supabase;

  PayrollRulesDataSource({required this.supabase});

  Future<List<PayrollRuleEntity>> getPayrollRules(String tenantId) async {
    final res =
        await supabase.from('payroll_rules').select().eq('tenant_id', tenantId);

    return (res as List)
        .map((e) => PayrollRuleEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PayrollRuleEntity> createPayrollRule(PayrollRuleEntity rule) async {
    final res = await supabase
        .from('payroll_rules')
        .insert(rule.toJson(forInsert: true))
        .select()
        .single();

    return PayrollRuleEntity.fromJson(res);
  }

  Future<PayrollRuleEntity> updatePayrollRule(PayrollRuleEntity rule) async {
    final res = await supabase
        .from('payroll_rules')
        .update(rule.toJson())
        .eq('id', rule.id)
        .select()
        .single();

    return PayrollRuleEntity.fromJson(res);
  }

  Future<void> deletePayrollRule(String id) async {
    await supabase.from('payroll_rules').delete().eq('id', id);
  }
}

import 'package:manzoma/features/attendance/data/models/attendance_rule_model.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AttendanceRulesRemoteDataSource {
  Future<List<AttendanceRuleEntity>> getRules(String tenantId);
  Future<AttendanceRuleEntity> addRule(AttendanceRuleEntity data);
  Future<void> assignRuleToUser(
      String userId, Map<String, dynamic> ruleDetails);

  Future<Map<String, dynamic>> getMetrics(String userId, DateTime date);
  Future<AttendanceRuleEntity> updateRule(AttendanceRuleEntity data);
}

class AttendanceRulesRemoteDataSourceImpl
    implements AttendanceRulesRemoteDataSource {
  final SupabaseClient supabase;

  AttendanceRulesRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<AttendanceRuleEntity>> getRules(String tenantId) async {
    final res = await supabase
        .from('attendance_rules')
        .select()
        .eq('tenant_id', tenantId);

    return (res as List)
        .map((e) => AttendanceRuleModel.fromJson(e))
        .toList()
        .cast<AttendanceRuleEntity>();
  }

  @override
  Future<AttendanceRuleEntity> addRule(AttendanceRuleEntity data) async {
    final res = await supabase
        .from('attendance_rules')
        .insert(data.toJson(forInsert: true))
        .select()
        .single();

    return AttendanceRuleEntity.fromJson(res);
  }

  @override
  Future<AttendanceRuleEntity> updateRule(AttendanceRuleEntity data) async {
    final res = await supabase
        .from('attendance_rules')
        .update(data.toJson(forInsert: false)) // نستخدم update مش insert
        .eq('id', data.id) // نحدد السجل
        .select()
        .single();

    return AttendanceRuleEntity.fromJson(res);
  }

  @override
  Future<void> assignRuleToUser(
      String userId, Map<String, dynamic> ruleDetails) async {
    await supabase.from('users').update({
      'work_schedule': ruleDetails,
    }).eq('id', userId);
  }

  @override
  Future<Map<String, dynamic>> getMetrics(String userId, DateTime date) async {
    final res = await supabase.rpc('compute_shift_metrics', params: {
      'p_user_id': userId,
      'p_date': date.toIso8601String().split('T')[0],
    });

    if (res.error != null) {
      throw Exception("Supabase error: ${res.error!.message}");
    }

    return Map<String, dynamic>.from(res.data as Map);
  }
}

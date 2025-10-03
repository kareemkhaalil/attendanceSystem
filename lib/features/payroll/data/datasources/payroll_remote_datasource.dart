// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../../core/error/exceptions.dart';
// import '../models/payroll_model.dart';

// abstract class PayrollRemoteDataSource {
//   Future<PayrollModel> createPayroll({
//     required String userId,
//     required String period,
//     required double basicSalary,
//     double allowances = 0,
//     double deductions = 0,
//     double overtime = 0,
//     double bonus = 0,
//     required int workingDays,
//     required int actualWorkingDays,
//     String? notes,
//   });

//   Future<List<PayrollModel>> getPayrollHistory({
//     required String userId,
//     String? period,
//     int? limit,
//     int? offset,
//   });

//   Future<List<PayrollModel>> getAllPayrolls({
//     String? period,
//     String? status,
//     int? limit,
//     int? offset,
//   });

//   Future<PayrollModel> updatePayroll({
//     required String payrollId,
//     double? basicSalary,
//     double? allowances,
//     double? deductions,
//     double? overtime,
//     double? bonus,
//     int? workingDays,
//     int? actualWorkingDays,
//     String? status,
//     String? notes,
//   });

//   Future<void> deletePayroll({required String payrollId});

//   Future<PayrollModel> approvePayroll({required String payrollId});

//   Future<PayrollModel> markAsPaid({required String payrollId});
// }

// class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
//   final SupabaseClient supabaseClient;

//   PayrollRemoteDataSourceImpl({required this.supabaseClient});

//   @override
//   Future<PayrollModel> createPayroll({
//     required String userId,
//     required String period,
//     required double basicSalary,
//     double allowances = 0,
//     double deductions = 0,
//     double overtime = 0,
//     double bonus = 0,
//     required int workingDays,
//     required int actualWorkingDays,
//     String? notes,
//   }) async {
//     try {
//       // Get user info
//       final userProfile = await supabaseClient
//           .from('profiles')
//           .select('name')
//           .eq('id', userId)
//           .single();

//       // Calculate net salary
//       final netSalary =
//           basicSalary + allowances + overtime + bonus - deductions;

//       final payrollData = {
//         'user_id': userId,
//         'user_name': userProfile['name'],
//         'period': period,
//         'basic_salary': basicSalary,
//         'allowances': allowances,
//         'deductions': deductions,
//         'overtime': overtime,
//         'bonus': bonus,
//         'net_salary': netSalary,
//         'working_days': workingDays,
//         'actual_working_days': actualWorkingDays,
//         'status': 'draft',
//         'notes': notes,
//         'created_at': DateTime.now().toIso8601String(),
//         'updated_at': DateTime.now().toIso8601String(),
//       };

//       final response = await supabaseClient
//           .from('payroll')
//           .insert(payrollData)
//           .select()
//           .single();

//       return PayrollModel.fromJson(response);
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }

//   @override
//   Future<List<PayrollModel>> getPayrollHistory({
//     required String userId,
//     String? period,
//     int? limit,
//     int? offset,
//   }) async {
//     try {
//       dynamic query =
//           supabaseClient.from('payroll').select().eq('user_id', userId);

//       if (period != null) {
//         query = query.eq('period', period);
//       }

//       query = query.order('period', ascending: false);

//       if (limit != null) {
//         query = query.limit(limit);
//       }

//       if (offset != null) {
//         query = query.range(offset, offset + (limit ?? 10) - 1);
//       }

//       final response = await query;

//       return response.map((json) => PayrollModel.fromJson(json)).toList();
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }

//   @override
//   Future<List<PayrollModel>> getAllPayrolls({
//     String? period,
//     String? status,
//     int? limit,
//     int? offset,
//   }) async {
//     try {
//       dynamic query = supabaseClient.from('payroll').select();

//       if (period != null) {
//         query = query.eq('period', period);
//       }

//       if (status != null) {
//         query = query.eq('status', status);
//       }

//       query = query.order('period', ascending: false);

//       if (limit != null) {
//         query = query.limit(limit);
//       }

//       if (offset != null) {
//         query = query.range(offset, offset + (limit ?? 10) - 1);
//       }

//       final response = await query;

//       return response.map((json) => PayrollModel.fromJson(json)).toList();
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }

//   @override
//   Future<PayrollModel> updatePayroll({
//     required String payrollId,
//     double? basicSalary,
//     double? allowances,
//     double? deductions,
//     double? overtime,
//     double? bonus,
//     int? workingDays,
//     int? actualWorkingDays,
//     String? status,
//     String? notes,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{
//         'updated_at': DateTime.now().toIso8601String(),
//       };

//       if (basicSalary != null) updateData['basic_salary'] = basicSalary;
//       if (allowances != null) updateData['allowances'] = allowances;
//       if (deductions != null) updateData['deductions'] = deductions;
//       if (overtime != null) updateData['overtime'] = overtime;
//       if (bonus != null) updateData['bonus'] = bonus;
//       if (workingDays != null) updateData['working_days'] = workingDays;
//       if (actualWorkingDays != null)
//         updateData['actual_working_days'] = actualWorkingDays;
//       if (status != null) updateData['status'] = status;
//       if (notes != null) updateData['notes'] = notes;

//       // Recalculate net salary if any salary components changed
//       if (basicSalary != null ||
//           allowances != null ||
//           deductions != null ||
//           overtime != null ||
//           bonus != null) {
//         // Get current values first
//         final current = await supabaseClient
//             .from('payroll')
//             .select('basic_salary, allowances, deductions, overtime, bonus')
//             .eq('id', payrollId)
//             .single();

//         final newBasicSalary = basicSalary ?? current['basic_salary'];
//         final newAllowances = allowances ?? current['allowances'];
//         final newDeductions = deductions ?? current['deductions'];
//         final newOvertime = overtime ?? current['overtime'];
//         final newBonus = bonus ?? current['bonus'];

//         updateData['net_salary'] = newBasicSalary +
//             newAllowances +
//             newOvertime +
//             newBonus -
//             newDeductions;
//       }

//       final response = await supabaseClient
//           .from('payroll')
//           .update(updateData)
//           .eq('id', payrollId)
//           .select()
//           .single();

//       return PayrollModel.fromJson(response);
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }

//   @override
//   Future<void> deletePayroll({required String payrollId}) async {
//     try {
//       await supabaseClient.from('payroll').delete().eq('id', payrollId);
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }

//   @override
//   Future<PayrollModel> approvePayroll({required String payrollId}) async {
//     try {
//       final response = await supabaseClient
//           .from('payroll')
//           .update({
//             'status': 'approved',
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('id', payrollId)
//           .select()
//           .single();

//       return PayrollModel.fromJson(response);
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }

//   @override
//   Future<PayrollModel> markAsPaid({required String payrollId}) async {
//     try {
//       final response = await supabaseClient
//           .from('payroll')
//           .update({
//             'status': 'paid',
//             'updated_at': DateTime.now().toIso8601String(),
//           })
//           .eq('id', payrollId)
//           .select()
//           .single();

//       return PayrollModel.fromJson(response);
//     } on PostgrestException catch (e) {
//       throw ServerException(
//         message: e.message,
//         statusCode: e.code != null ? int.tryParse(e.code!) : null,
//       );
//     } catch (e) {
//       throw ServerException(message: e.toString());
//     }
//   }
// }
import 'package:manzoma/features/payroll/data/models/payroll_detail_model.dart';
import 'package:manzoma/features/payroll/data/models/payroll_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PayrollRemoteDataSource {
  Future<List<PayrollModel>> getAllPayrolls(String tenantId);
  Future<PayrollModel?> getPayrollById(String payrollId);
  Future<PayrollModel?> createPayroll(PayrollModel payroll);
  Future<void> deletePayroll(String payrollId);
  Future<List<PayrollDetailModel>> generatePayrollEntries({
    required String payrollId,
    required String tenantId,
  });
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  final SupabaseClient client;
  PayrollRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PayrollModel>> getAllPayrolls(String tenantId) async {
    final response = await client
        .from('payroll')
        .select()
        .eq('tenant_id', tenantId) // لازم tenantId يكون UUID صحيح
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => PayrollModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PayrollModel?> getPayrollById(String payrollId) async {
    final response = await client
        .from('payroll')
        .select()
        .eq('id', payrollId)
        .maybeSingle(); // ✅ بدل single

    return response != null ? PayrollModel.fromJson(response) : null;
  }

  @override
  Future<List<PayrollDetailModel>> generatePayrollEntries({
    required String payrollId,
    required String tenantId,
  }) async {
    // 1. هات كل الموظفين في التينانت
    final users =
        await client.from('users').select('id').eq('tenant_id', tenantId);

    final List<PayrollDetailModel> entries = [];

    for (final u in users) {
      final userId = u['id'] as String;

      // 2. نجيب الـ Metrics (Attendance) من الـ RPC
      final metrics = await client.rpc('compute_shift_metrics', params: {
        'p_user_id': userId,
        'p_date':
            DateTime.now().toIso8601String().split('T')[0], // مبدئيًا يومي
      });

      // 3. نجيب Payroll Rules بتاعت الموظف
      final rules = await client
          .from('employee_salary_rules')
          .select('payroll_rules(*)')
          .eq('user_id', userId);

      // 4. نحسب الراتب المبدئي
      double netPay = 0;
      for (final r in rules) {
        final rule = r['payroll_rules'];
        if (rule['type'] == 'allowance') {
          netPay += rule['amount'];
        } else if (rule['type'] == 'deduction') {
          netPay -= rule['amount'];
        }
      }

      // خصومات الغياب / التأخير / إضافي
      final late =
          (metrics['lateness_minutes'] ?? 0) * 2; // مثال: 2 جنيه للدقيقة
      final overtime = (metrics['overtime_minutes'] ?? 0) * 1.5; // مثال

      netPay = netPay - late + overtime;

      // 5. خزّن entry
      final inserted = await client
          .from('payroll_details')
          .insert({
            'payroll_id': payrollId,
            'user_id': userId,
            'worked_hours': metrics['worked_hours'] ?? 0,
            'lateness_minutes': metrics['lateness_minutes'] ?? 0,
            'overtime_minutes': metrics['overtime_minutes'] ?? 0,
            'net_pay': netPay,
          })
          .select()
          .single();

      entries.add(PayrollDetailModel.fromJson(inserted));
    }

    return entries;
  }

  @override
  Future<PayrollModel?> createPayroll(PayrollModel payroll) async {
    final response = await client
        .from('payroll')
        .insert(payroll.toJson())
        .select()
        .maybeSingle(); // ✅ بدل single

    return response != null ? PayrollModel.fromJson(response) : null;
  }

  @override
  Future<void> deletePayroll(String payrollId) async {
    await client.from('payroll').delete().eq('id', payrollId);
  }
}

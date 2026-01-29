import '../models/payroll_detail_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PayrollDetailRemoteDataSource {
  Future<List<PayrollDetailModel>> getDetailsByPayrollId(String payrollId);
  Future<PayrollDetailModel> addDetail(PayrollDetailModel detail);
  Future<void> deleteDetail(String detailId);
}

class PayrollDetailRemoteDataSourceImpl
    implements PayrollDetailRemoteDataSource {
  final SupabaseClient client;
  PayrollDetailRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PayrollDetailModel>> getDetailsByPayrollId(
      String payrollId) async {
    final response = await client
        .from('payroll_details')
        .select()
        .eq('payroll_id', payrollId);

    return (response as List)
        .map((e) => PayrollDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PayrollDetailModel> addDetail(PayrollDetailModel detail) async {
    final response = await client
        .from('payroll_details')
        .insert(detail.toJson())
        .select()
        .maybeSingle();
    return PayrollDetailModel.fromJson(response!);
  }

  @override
  Future<void> deleteDetail(String detailId) async {
    await client.from('payroll_details').delete().eq('id', detailId);
  }
}

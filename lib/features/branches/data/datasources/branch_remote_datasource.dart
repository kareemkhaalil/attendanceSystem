import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/branch_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getBranches({
    String? tenantId,
    int? limit,
    int? offset,
  });

  Future<BranchModel> getBranchById(String id);

  Future<BranchModel> createBranch(BranchModel branch);

  Future<BranchModel> updateBranch(String id, BranchModel branch);

  Future<void> deleteBranch(String id);

  Future<List<BranchModel>> searchBranches(
    String query, {
    String? tenantId,
  });
}

class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  final SupabaseClient supabaseClient;

  BranchRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<BranchModel>> getBranches({
    String? tenantId,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = supabaseClient.from('branches').select();

      if (tenantId != null) {
        query = query.eq('tenant_id', tenantId);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => BranchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get branches: $e');
    }
  }

  @override
  Future<BranchModel> getBranchById(String id) async {
    try {
      final response = await supabaseClient
          .from('branches')
          .select()
          .eq('id', id)
          .maybeSingle();

      return BranchModel.fromJson(response!);
    } catch (e) {
      throw Exception('Failed to get branch: $e');
    }
  }

  @override
  Future<BranchModel> createBranch(BranchModel branch) async {
    try {
      final response = await supabaseClient
          .rpc(
            'create_branch_and_update_tenant', // اسم الدالة
            params: {
              'branch_data': branch.toCreateJson()
            }, // تمرير البيانات كـ JSON
          )
          .select()
          .maybeSingle();

      print('Response from createBranch: $response');
      return BranchModel.fromJson(response!);
    } catch (e) {
      print('Error occurred while creating branch: $e');
      throw Exception('Failed to create branch: $e');
    }
  }

  @override
  Future<BranchModel> updateBranch(String id, BranchModel branch) async {
    try {
      final response = await supabaseClient
          .from('branches')
          .update(branch.toCreateJson())
          .eq('id', id)
          .select()
          .maybeSingle();

      return BranchModel.fromJson(response!);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  @override
  Future<void> deleteBranch(String id) async {
    try {
      await supabaseClient.from('branches').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }

  @override
  Future<List<BranchModel>> searchBranches(
    String query, {
    String? tenantId,
  }) async {
    try {
      var supabaseQuery = supabaseClient
          .from('branches')
          .select()
          .or('name.ilike.%$query%,address.ilike.%$query%');

      if (tenantId != null) {
        supabaseQuery = supabaseQuery.eq('tenant_id', tenantId);
      }

      final response = await supabaseQuery;

      return (response as List<dynamic>)
          .map((json) => BranchModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search branches: $e');
    }
  }
}

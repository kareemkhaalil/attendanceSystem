import 'package:manzoma/core/enums/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers({
    String? tenantId,
    String? branchId,
    UserRole? role,
    int? limit,
    int? offset,
  });

  Future<UserModel> getUserById(String id);

  Future<UserModel> createUser(UserModel user);

  Future<UserModel> updateUser(String id, UserModel user);

  Future<void> deleteUser(String id);

  Future<List<UserModel>> searchUsers(
    String query, {
    String? tenantId,
    String? role,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<UserModel>> getUsers({
    String? tenantId,
    String? branchId,
    UserRole? role,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = supabaseClient.from('users').select();

      if (tenantId != null) {
        query = query.eq('tenant_id', tenantId);
      }

      if (branchId != null) {
        query = query.eq('branch_id', branchId);
      }

      if (role != null) {
        query = query.eq('role', role.toValue());
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await supabaseClient
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      return UserModel.fromJson(response!);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      // 1. Check if user already exists by email
      final existingUser = await supabaseClient
          .from('users')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      // 2. Sign up the auth user
      final AuthResponse res = await supabaseClient.auth.signUp(
        email: user.email,
        password: user.password ?? 'example-password',
      );

      final supabaseUser = res.user;
      if (supabaseUser == null) {
        throw Exception('Failed to create Supabase auth user');
      }

      // 3. Prepare user payload without password
      final userDataPayload = user.toCreateJson();
      userDataPayload['id'] = supabaseUser.id; // use auth id as PK
      userDataPayload.remove('password');

      // 4. Upsert into users table (avoids duplicate key error on retry)
      final insertedUser = await supabaseClient
          .from('users')
          .upsert(userDataPayload, onConflict: 'id')
          .select()
          .maybeSingle();

      // 5. Increment tenant counter directly in DB
      await supabaseClient.rpc(
        'increment_current_users',
        params: {'p_tenant_id': insertedUser!['tenant_id']},
      );

      // 6. Return mapped user
      return UserModel.fromJson(insertedUser);
    } catch (e) {
      print('error in createUser: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<UserModel> updateUser(String id, UserModel user) async {
    try {
      final response = await supabaseClient
          .from('users')
          .update(user.toCreateJson())
          .eq('id', id)
          .select()
          .maybeSingle();

      return UserModel.fromJson(response!);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await supabaseClient.from('users').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(
    String query, {
    String? tenantId,
    String? role,
  }) async {
    try {
      var supabaseQuery = supabaseClient
          .from('users')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%');

      if (tenantId != null) {
        supabaseQuery = supabaseQuery.eq('tenant_id', tenantId);
      }

      if (role != null) {
        supabaseQuery = supabaseQuery.eq('role', role);
      }

      final response = await supabaseQuery;

      return (response as List<dynamic>)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}

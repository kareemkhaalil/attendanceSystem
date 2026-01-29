import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients({
    int? limit,
    int? offset,
  });

  Future<ClientModel> getClientById(String id);

  Future<ClientModel> createClient({
    required String name,
    required String plan,
    required DateTime subscriptionStart,
    required DateTime subscriptionEnd,
    required double billingAmount,
    required String billingInterval,
  });

  Future<ClientModel> updateClient({
    required String id,
    String? name,
    String? plan,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    double? billingAmount,
    String? billingInterval,
    bool? isActive,
  });

  Future<void> deleteClient(String id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final SupabaseClient supabaseClient;

  ClientRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ClientModel>> getClients({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = supabaseClient
          .from('tenants')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => ClientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch clients: $e');
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final response = await supabaseClient
          .from('tenants')
          .select()
          .eq('id', id)
          .maybeSingle();

      return ClientModel.fromJson(response!);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch client: $e');
    }
  }

  @override
  @override
  Future<ClientModel> createClient({
    required String name,
    required String plan,
    required DateTime subscriptionStart,
    required DateTime subscriptionEnd,
    required double billingAmount,
    required String billingInterval,
    bool isActive = true,
    int allowedBranches = 1,
    int allowedUsers = 5,
  }) async {
    try {
      print('Creating client with name: $name, plan: $plan');

      final response = await supabaseClient
          .from('tenants')
          .insert({
            'name': name,
            'plan': plan,
            'subscription_start': subscriptionStart.toIso8601String(),
            'subscription_end': subscriptionEnd.toIso8601String(),
            'billing_amount': billingAmount,
            'billing_interval': billingInterval,
            'is_active': isActive,
            'allowed_branches': allowedBranches,
            'allowed_users': allowedUsers,
            'current_branches': 0,
            'current_users': 0,
          })
          .select()
          .maybeSingle();

      print('Client created successfully: $response');
      return ClientModel.fromJson(response!);
    } catch (e) {
      print('Error creating client: $e');
      throw ServerException(message: 'Failed to create client: $e');
    }
  }

  @override
  Future<ClientModel> updateClient({
    required String id,
    String? name,
    String? plan,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    double? billingAmount,
    String? billingInterval,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (plan != null) updateData['plan'] = plan;
      if (subscriptionStart != null)
        updateData['subscription_start'] = subscriptionStart.toIso8601String();
      if (subscriptionEnd != null)
        updateData['subscription_end'] = subscriptionEnd.toIso8601String();
      if (billingAmount != null) updateData['billing_amount'] = billingAmount;
      if (billingInterval != null)
        updateData['billing_interval'] = billingInterval;
      if (isActive != null) updateData['is_active'] = isActive;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabaseClient
          .from('tenants')
          .update(updateData)
          .eq('id', id)
          .select()
          .maybeSingle();

      return ClientModel.fromJson(response!);
    } catch (e) {
      throw ServerException(message: 'Failed to update client: $e');
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await supabaseClient.from('tenants').delete().eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Failed to delete client: $e');
    }
  }
}

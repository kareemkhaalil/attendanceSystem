import 'package:manzoma/core/location/location_helper.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> checkIn({
    required String userId,
    required String location,
    String? notes,
  });

  Future<AttendanceModel> checkOut({
    required String attendanceId,
    String? notes,
  });

  Future<List<AttendanceModel>> getAttendanceHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Future<List<AttendanceModel>> getAttendanceHistoryByTenant({
    required String tenantId,
    int? limit,
    int? offset,
  });

  Future<List<AttendanceModel>> getAllAttendance({
    DateTime? date,
    String? userId,
    int? limit,
    int? offset,
  });

  Future<AttendanceModel> updateAttendance({
    required String attendanceId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  });
  Future<AttendanceModel> checkInWithQr({
    required String token,
    required double lat,
    required double lng,
  });

  Future<void> deleteAttendance({required String attendanceId});
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final SupabaseClient supabaseClient;

  AttendanceRemoteDataSourceImpl({required this.supabaseClient});
  @override
  Future<AttendanceModel> checkIn({
    required String userId,
    required String location,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // ✅ Get current location
      final currentLocation = await LocationHelper.getCurrentLocation();
      final double currentLat = currentLocation.latitude;
      final double currentLng = currentLocation.longitude;

      // ✅ Get user profile with client_id
      final userProfile = await supabaseClient
          .from('users')
          .select('name, tenant_id')
          .eq('id', userId)
          .maybeSingle();

      final clientId = userProfile!['tenant_id'];

      if (clientId == null) {
        throw ServerException(message: "المستخدم غير مرتبط بعميل");
      }

      // ✅ Get all branches for this client
      final branches = await supabaseClient
          .from('branches')
          .select('id, name, latitude, longitude, radius_meters')
          .eq('tenant_id', clientId);

      if (branches.isEmpty) {
        throw ServerException(message: "لم يتم العثور على أي فروع للعميل");
      }

      // ✅ Check if user is inside any branch radius
      Map<String, dynamic>? matchedBranch;
      double? matchedDistance;

      for (final branch in branches) {
        final branchLat = (branch['latitude'] as num).toDouble();
        final branchLng = (branch['longitude'] as num).toDouble();
        final branchRadius = (branch['radius_meters'] as num).toDouble();

        final distance = LocationHelper.calculateDistanceMeters(
          currentLat,
          currentLng,
          branchLat,
          branchLng,
        );

        if (distance <= branchRadius) {
          matchedBranch = branch;
          matchedDistance = distance;
          break; // أول فرع لقيناه كفاية
        }
      }

      if (matchedBranch == null) {
        throw ServerException(message: "أنت خارج نطاق أي فرع تابع لهذا العميل");
      }

      // ✅ Check if already checked in today
      // final existingAttendance = await supabaseClient
      //     .from('attendance_with_users')
      //     .select()
      //     .eq('user_id', userId)
      //     .eq('date', today.toIso8601String().split('T')[0])
      //     .maybeSingle();

      // if (existingAttendance != null) {
      //   throw const ServerException(
      //       message: 'تم تسجيل الحضور مسبقاً لهذا اليوم');
      // }

      final attendanceData = {
        'user_id': userId,
        // 'user_name': userProfile['name'],
        'branch_id': matchedBranch['id'],
        'tenant_id': clientId,
        'date': today.toIso8601String().split('T')[0],
        'check_in_time': now.toIso8601String(),
        'status': 'present',
        // 'check_in_lat': currentLat,
        // 'check_in_lng': currentLng,
        'notes': notes,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await supabaseClient
          .from('attendance_with_users')
          .insert(attendanceData)
          .select()
          .maybeSingle();

      return AttendanceModel.fromJson(response!);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      print("Error occurred while checking in datasource: ${e.toString()}");
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AttendanceModel> checkInWithQr({
    // required String userId, // userId is now handled within the RPC function
    required String token,
    required double lat,
    required double lng,
  }) async {
    final res = await supabaseClient.rpc('verify_qr_and_checkin', params: {
      'p_token': token,
      'p_lat': lat,
      'p_lng': lng,
    });

    if (res.error != null) {
      throw ServerException(message: res.error!.message);
    }

    final data = res.data as List;
    if (data.isEmpty) throw const ServerException(message: 'No response');

    final row = data.first;
    if (row['success'] == false) {
      throw ServerException(message: row['message']);
    }

    // لو عندك model مخصص لـ attendance ممكن تبنيه من هنا
    return AttendanceModel(
      id: '', // supabase ممكن يرجع الـ id من attendance لو عدلنا الـ function
      userId: '', // This will be updated once the RPC returns the user_id
      userName: '',
      checkInTime: DateTime.now(),
      method: 'qr', date: DateTime.now(), status: AttendanceStatus.present,
      checkOutTime: DateTime.now(),
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
  }

  @override
  Future<AttendanceModel> checkOut({
    required String attendanceId,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();

      final updateData = {
        'check_out_time': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await supabaseClient
          .from('attendance_with_users')
          .update(updateData)
          .eq('id', attendanceId)
          .select()
          .maybeSingle();

      return AttendanceModel.fromJson(response!);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = supabaseClient
          .from('attendance_with_users')
          .select()
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      query = query.order('date', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query as List;

      return response
          .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistoryByTenant({
    required String tenantId,
    int? limit,
    int? offset,
  }) async {
    print('[DEBUG] tenantId sent: $tenantId');

    try {
      // ✅ استعلام أساسي: كل حضور مرتبط بالعميل
      dynamic query = supabaseClient
          .from('attendance_with_users')
          .select()
          .eq('tenant_id', tenantId);

      // ✅ ترتيب تنازلي بالتاريخ
      query = query.order('date', ascending: false);

      // ✅ pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      // ✅ تنفيذ الاستعلام
      final response = await query as List;
      print('[DEBUG] raw response: $response');

      // ✅ تحويل لـ Model
      return response
          .map((json) => AttendanceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      print(' error in database : ${e.message}');
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      print('error server : $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AttendanceModel>> getAllAttendance({
    DateTime? date,
    String? userId,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = supabaseClient.from('attendance_with_users').select();

      if (date != null) {
        query = query.eq('date', date.toIso8601String().split('T')[0]);
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      query = query.order('date', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return response.map((json) => AttendanceModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AttendanceModel> updateAttendance({
    required String attendanceId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (checkInTime != null) {
        updateData['check_in_time'] = checkInTime.toIso8601String();
      }

      if (checkOutTime != null) {
        updateData['check_out_time'] = checkOutTime.toIso8601String();
      }

      if (status != null) {
        updateData['status'] = status;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await supabaseClient
          .from('attendance_with_users')
          .update(updateData)
          .eq('id', attendanceId)
          .select()
          .maybeSingle();

      return AttendanceModel.fromJson(response!);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAttendance({required String attendanceId}) async {
    try {
      await supabaseClient
          .from('attendance_with_users')
          .delete()
          .eq('id', attendanceId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: e.code != null ? int.tryParse(e.code!) : null,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

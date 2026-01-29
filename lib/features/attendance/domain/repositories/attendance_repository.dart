import 'package:dartz/dartz.dart';
import 'package:manzoma/features/attendance/domain/usecases/get_attendance_history_tennent_usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity>> checkIn({
    required String userId,
    required String location,
    String? notes,
  });
  Future<Either<Failure, AttendanceEntity>> checkInWithQr({
    required String token,
    required double lat,
    required double lng,
  });

  Future<Either<Failure, AttendanceEntity>> checkOut({
    required String attendanceId,
    String? notes,
  });

  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistoryByTenant({
    required String tenantId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<AttendanceEntity>>> getAllAttendance({
    DateTime? date,
    String? userId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, AttendanceEntity>> updateAttendance({
    required String attendanceId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  });

  Future<Either<Failure, void>> deleteAttendance(
      {required String attendanceId});
}

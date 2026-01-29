import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AttendanceEntity>> checkIn({
    required String userId,
    required String location,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendance = await remoteDataSource.checkIn(
          userId: userId,
          location: location,
          notes: notes,
        );
        return Right(attendance);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkInWithQr({
    required String token,
    required double lat,
    required double lng,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendance = await remoteDataSource.checkInWithQr(
          token: token,
          lat: lat,
          lng: lng,
        );
        return Right(attendance);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkOut({
    required String attendanceId,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendance = await remoteDataSource.checkOut(
          attendanceId: attendanceId,
          notes: notes,
        );
        return Right(attendance);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendanceList = await remoteDataSource.getAttendanceHistory(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
          offset: offset,
        );
        return Right(attendanceList);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  // create getAttendanceHistoryByTenant
  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistoryByTenant({
    required String tenantId,
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendanceList =
            await remoteDataSource.getAttendanceHistoryByTenant(
          tenantId: tenantId,
          limit: limit,
          offset: offset,
        );
        print('[DEBUG] attendanceList: $attendanceList');
        return Right(attendanceList);
      } on ServerException catch (e) {
        print('[DEBUG] ServerException: ${e.message}');
        return Left(ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAllAttendance({
    DateTime? date,
    String? userId,
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendanceList = await remoteDataSource.getAllAttendance(
          date: date,
          userId: userId,
          limit: limit,
          offset: offset,
        );
        return Right(attendanceList);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> updateAttendance({
    required String attendanceId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final attendance = await remoteDataSource.updateAttendance(
          attendanceId: attendanceId,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          status: status,
          notes: notes,
        );
        return Right(attendance);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        'لا يوجد اتصال بالإنترنت',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttendance({
    required String attendanceId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAttendance(attendanceId: attendanceId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          statusCode: e.statusCode,
        ));
      }
    } else {
      return const Left(NetworkFailure(
        'لا يوجد اتصال بالإنترنت',
      ));
    }
  }
}

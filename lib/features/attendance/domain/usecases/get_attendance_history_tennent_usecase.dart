import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:manzoma/core/error/failures.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_entity.dart';
import 'package:manzoma/features/attendance/domain/repositories/attendance_repository.dart';

class GetAttendanceHistoryByTennentidUseCase {
  final AttendanceRepository repository;

  GetAttendanceHistoryByTennentidUseCase(this.repository);
  @override
  Future<Either<Failure, List<AttendanceEntity>>> call(
      GetAttendanceHistoryByTennentidParams params) async {
    return await repository.getAttendanceHistoryByTenant(
      tenantId: params.tenantId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetAttendanceHistoryByTennentidParams extends Equatable {
  final String tenantId;

  final int? limit;
  final int? offset;

  const GetAttendanceHistoryByTennentidParams({
    required this.tenantId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [tenantId, limit, offset];
}

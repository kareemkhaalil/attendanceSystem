import 'package:dartz/dartz.dart';

import 'package:manzoma/core/error/failures.dart';

import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckInWithQrUseCase {
  final AttendanceRepository repository;

  CheckInWithQrUseCase(this.repository);

  Future<Either<Failure, AttendanceEntity>> call(CheckInWithQrParams params) {
    return repository.checkInWithQr(
      token: params.token,
      lat: params.lat,
      lng: params.lng,
    );
  }
}

class CheckInWithQrParams {
  final String token; // اللي معمول encode في الـ QR
  final double lat;
  final double lng;

  CheckInWithQrParams({
    required this.token,
    required this.lat,
    required this.lng,
  });
}

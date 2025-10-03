import 'package:equatable/equatable.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceCheckInSuccess extends AttendanceState {
  final AttendanceEntity attendance;

  const AttendanceCheckInSuccess({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceCheckOutSuccess extends AttendanceState {
  final AttendanceEntity attendance;

  const AttendanceCheckOutSuccess({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceEntity> attendanceList;
  final bool hasReachedMax;

  const AttendanceHistoryLoaded({
    required this.attendanceList,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [attendanceList, hasReachedMax];

  AttendanceHistoryLoaded copyWith({
    List<AttendanceEntity>? attendanceList,
    bool? hasReachedMax,
  }) {
    return AttendanceHistoryLoaded(
      attendanceList: attendanceList ?? this.attendanceList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object> get props => [message];
}

class AttendanceRuleAssigned extends AttendanceState {}

class AttendanceMetricsLoaded extends AttendanceState {
  final Map<String, dynamic> metrics;
  const AttendanceMetricsLoaded({required this.metrics});

  @override
  List<Object?> get props => [metrics];
}

class AttendanceRulesLoading extends AttendanceState {}

class AttendanceRulesLoaded extends AttendanceState {
  final List<AttendanceRuleEntity> rules;
  const AttendanceRulesLoaded({required this.rules});

  @override
  @override
  List<Object?> get props => [rules, DateTime.now()];
}

class AttendanceRulesError extends AttendanceState {
  final String message;
  const AttendanceRulesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AttendanceMetricsError extends AttendanceState {
  final String message;
  const AttendanceMetricsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/* =========================
   حالات جلسة الـ QR (موحّدة هنا)
   ========================= */

class AttendanceQrCreating extends AttendanceState {}

class AttendanceQrActive extends AttendanceState {
  final String sessionId;
  final String tokenHex;
  final DateTime? expiresAt;
  final int windowSeconds;
  final String qrText;
  final int remainingSeconds;

  const AttendanceQrActive({
    required this.sessionId,
    required this.tokenHex,
    required this.expiresAt,
    required this.windowSeconds,
    required this.qrText,
    required this.remainingSeconds,
  });

  AttendanceQrActive copyWith({
    String? qrText,
    int? remainingSeconds,
  }) {
    return AttendanceQrActive(
      sessionId: sessionId,
      tokenHex: tokenHex,
      expiresAt: expiresAt,
      windowSeconds: windowSeconds,
      qrText: qrText ?? this.qrText,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props =>
      [sessionId, tokenHex, expiresAt, windowSeconds, qrText, remainingSeconds];
}

class AttendanceQrExpired extends AttendanceState {}

class AttendanceQrError extends AttendanceState {
  final String message;

  const AttendanceQrError(this.message);

  @override
  List<Object?> get props => [message];
}

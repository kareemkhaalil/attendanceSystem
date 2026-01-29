// lib/features/attendance/presentation/cubit/attendance_qr_cubit.dart
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';

sealed class AttendanceQrState {}

class QrInitial extends AttendanceQrState {}

class QrCreating extends AttendanceQrState {}

class QrActive extends AttendanceQrState {
  final String sessionId;
  final String tokenHex;
  final DateTime? expiresAt;
  final int windowSeconds;
  final String qrText;
  final int remainingSeconds;

  QrActive({
    required this.sessionId,
    required this.tokenHex,
    required this.expiresAt,
    required this.windowSeconds,
    required this.qrText,
    required this.remainingSeconds,
  });

  QrActive copyWith({
    String? qrText,
    int? remainingSeconds,
  }) {
    return QrActive(
      sessionId: sessionId,
      tokenHex: tokenHex,
      expiresAt: expiresAt,
      windowSeconds: windowSeconds,
      qrText: qrText ?? this.qrText,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

class QrExpired extends AttendanceQrState {}

class QrError extends AttendanceQrState {
  final String message;
  QrError(this.message);
}

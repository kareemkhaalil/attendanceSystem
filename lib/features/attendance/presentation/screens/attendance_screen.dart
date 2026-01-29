import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';
import '../../../../shared/widgets/custom_button.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({super.key});
  final user = SharedPrefHelper.getUser();

  @override
  Widget build(BuildContext context) {
    print(' screen tenant id : ${user!.tenantId}');

    return BlocProvider(
      create: (context) => AttendanceCubit()
        ..getAttendanceHistoryByTenant(
            tenantId: user!.tenantId.toString(), refresh: true),
      child: const AttendanceView(),
    );
  }
}

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final ScrollController _scrollController = ScrollController();
  final user = SharedPrefHelper.getUser();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      print(' screen tenant id : ${user!.tenantId}');
      context.read<AttendanceCubit>().getAttendanceHistoryByTenant(
            tenantId: user!.tenantId.toString(),
            refresh: false,
          );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Check In/Out Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Time',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            return Text(
                              DateFormat('HH:mm:ss').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  BlocConsumer<AttendanceCubit, AttendanceState>(
                    listener: (context, state) {
                      if (state is AttendanceCheckInSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تسجيل الحضور بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is AttendanceCheckOutSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تسجيل الانصراف بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is AttendanceError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return Row(
                        children: [
                          CustomButton(
                            text: 'Check In',
                            isLoading: state is AttendanceLoading,
                            onPressed: () {
                              context.read<AttendanceCubit>().checkIn(
                                    userId: 'current-user-id',
                                    location: 'Office',
                                    notes: 'Regular check-in',
                                  );
                            },
                            backgroundColor: Colors.green,
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            text: 'Check Out',
                            isLoading: state is AttendanceLoading,
                            onPressed: () {
                              context.read<AttendanceCubit>().checkOut(
                                    attendanceId: 'attendance-id',
                                    notes: 'Regular check-out',
                                  );
                            },
                            backgroundColor: Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Attendance History
            const Text(
              'Attendance History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  final user = SharedPrefHelper.getUser();
                  if (state is AttendanceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AttendanceHistoryLoaded) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.attendanceList.length +
                          (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.attendanceList.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final attendance = state.attendanceList[index];
                        return Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _getStatusColor(attendance.status),
                              child: Icon(
                                _getStatusIcon(attendance.status),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              DateFormat('EEEE, MMM dd, yyyy')
                                  .format(attendance.date),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (attendance.checkInTime != null)
                                  Text(
                                      'Check In: ${DateFormat('HH:mm').format(attendance.checkInTime!)}'),
                                if (attendance.checkOutTime != null)
                                  Text(
                                      'Check Out: ${DateFormat('HH:mm').format(attendance.checkOutTime!)}'),
                                if (attendance.workingHours != null)
                                  Text(
                                      'Working Hours: ${attendance.workingHours}h'),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(attendance.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                attendance.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(attendance.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is AttendanceError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              print(' screen tenant id : ${user!.tenantId}');

                              context
                                  .read<AttendanceCubit>()
                                  .getAttendanceHistoryByTenant(
                                    tenantId: user.tenantId.toString(),
                                    refresh: true,
                                  );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No attendance data'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'AttendanceStatus.present':
        return Colors.green;
      case 'AttendanceStatus.late':
        return Colors.orange;
      case 'AttendanceStatus.absent':
        return Colors.red;
      case 'AttendanceStatus.earlyLeave':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(status) {
    switch (status.toString()) {
      case 'AttendanceStatus.present':
        return Icons.check_circle;
      case 'AttendanceStatus.late':
        return Icons.schedule;
      case 'AttendanceStatus.absent':
        return Icons.cancel;
      case 'AttendanceStatus.earlyLeave':
        return Icons.exit_to_app;
      default:
        return Icons.help;
    }
  }
}

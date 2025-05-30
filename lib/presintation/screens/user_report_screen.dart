import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bashkatep/core/bloc/attend_cubit/attendance_cubit.dart';
import 'package:bashkatep/presintation/screens/admin_screen.dart';
import 'package:bashkatep/presintation/screens/editUser_screen.dart';
import 'package:bashkatep/core/models/user_model.dart';

class UserReportsScreen extends StatelessWidget {
  final String clientId;

  const UserReportsScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttendanceCubit>();
    final Size size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => cubit..fetchUserReportsForToday(clientId),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تقارير المستخدمين'),
            backgroundColor: Colors.blueAccent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminScreen(clientId: clientId),
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  cubit.fetchUserReportsForToday(clientId);
                },
              ),
            ],
          ),
          body: BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UserReportsLoaded) {
                final userReports = state.user;
                return Container(
                  height: size.height,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'سجل الحضور والانصراف اليومي',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            width: size.width * 0.9,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('الاسم')),
                                  DataColumn(label: Text('تاريخ الدخول')),
                                  DataColumn(label: Text('تاريخ الخروج')),
                                  DataColumn(label: Text('حالة الحضور')),
                                ],
                                rows: userReports.map((userReport) {
                                  return DataRow(cells: [
                                    DataCell(
                                      Text(userReport.name),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserAttendanceDetailsScreen(
                                              clientId: clientId,
                                              userId: userReport.employeeId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    DataCell(Text(
                                        userReport.loginDate?.toString() ??
                                            'N/A')),
                                    DataCell(Text(
                                        userReport.logoutDate?.toString() ??
                                            'N/A')),
                                    DataCell(
                                      SizedBox.expand(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          color: userReport.attendanceStatus ==
                                                  'غائب'
                                              ? const Color.fromARGB(
                                                  255, 255, 91, 79)
                                              : const Color.fromARGB(
                                                  255, 80, 253, 126),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                userReport.attendanceStatus),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "الموظفين",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: Center(
                            child: Container(
                              width: size.width * 0.9,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: FutureBuilder<List<UserModel>>(
                                future: cubit.fetchUsers(clientId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No data found.'));
                                  } else {
                                    List<UserModel> users = snapshot.data!;
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            size.width > 600 ? 5 : 2,
                                        crossAxisSpacing:
                                            size.width > 600 ? 20.0 : 30,
                                        mainAxisSpacing:
                                            size.width > 600 ? 2.0 : 6.0,
                                      ),
                                      itemCount: users.length,
                                      itemBuilder: (context, index) {
                                        final user = users[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserAttendanceDetailsScreen(
                                                  userId: user.employeeId,
                                                  clientId: clientId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 3,
                                            color: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    user.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditUserScreenAdmin(
                                                            clientId: clientId,
                                                            user: user,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      size: size.width > 600
                                                          ? 30
                                                          : 20,
                                                      Icons.edit,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is AttendanceFailure) {
                return Center(child: Text('خطأ: ${state.error}'));
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class UserAttendanceDetailsScreen extends StatelessWidget {
  final String clientId;
  final String userId;

  const UserAttendanceDetailsScreen({
    super.key,
    required this.clientId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttendanceCubit>();
    final Size size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => cubit..fetchUserAttendanceDetails(clientId, userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الحضور'),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminScreen(clientId: clientId),
                ),
              );
            },
          ),
        ),
        body: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserAttendanceDetailsLoaded) {
              final attendanceDetails = state.attendanceDetails;
              final userName = state.userName;
              attendanceDetails
                  .sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: attendanceDetails.isEmpty
                        ? const Center(child: Text('No attendance details'))
                        : GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: size.width > 600 ? 5 : 2,
                              crossAxisSpacing: size.width > 600 ? 20.0 : 30,
                              mainAxisSpacing: size.width > 600 ? 8.0 : 50.0,
                            ),
                            itemCount: attendanceDetails.length,
                            itemBuilder: (context, index) {
                              final attendance = attendanceDetails[index];
                              return ListTile(
                                title: Text(
                                  'Session ${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Text('تسجيل الدخول: '),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ' ثانية : ${attendance.checkInTime.second}',
                                            ),
                                            Text(
                                              ' دقيقة : ${attendance.checkInTime.minute}',
                                            ),
                                            Text(
                                              ' ساعة : ${attendance.checkInTime.hour}',
                                            ),
                                            Text(
                                              ' اليوم : ${attendance.checkInTime.day}',
                                            ),
                                            Text(
                                              ' شهر : ${attendance.checkInTime.month}',
                                            ),
                                            Text(
                                              ' سنة : ${attendance.checkInTime.year}',
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Text('تسجيل الخروج: '),
                                        SizedBox(
                                          height: size.height * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              attendance.checkOutTime == null
                                                  ? [Text("N/A")]
                                                  : [
                                                      Text(
                                                        ' ثانية : ${attendance.checkOutTime!.second}',
                                                      ),
                                                      Text(
                                                        ' دقيقة : ${attendance.checkOutTime!.minute}',
                                                      ),
                                                      Text(
                                                        ' ساعة : ${attendance.checkOutTime!.hour}',
                                                      ),
                                                      Text(
                                                        ' اليوم : ${attendance.checkOutTime!.day}',
                                                      ),
                                                      Text(
                                                        ' شهر : ${attendance.checkOutTime!.month}',
                                                      ),
                                                      Text(
                                                        ' سنة : ${attendance.checkOutTime!.year}',
                                                      ),
                                                    ],
                                        ),
                                        SizedBox(
                                          height: size.height * 0.015,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            } else if (state is AttendanceFailure) {
              return Center(child: Text('خطأ: ${state.error}'));
            }
            return Container();
          },
        ),
      ),
    );
  }
}

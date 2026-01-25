import 'package:flutter/material.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart'; // تأكد من استيراد الـ Cubit

class DashboardStats extends StatelessWidget {
  final UserRole userRole;

  const DashboardStats({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    // استخدام BlocBuilder للاستماع إلى حالات DashboardCubit
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          // عرض شاشة تحميل أنيقة أثناء جلب البيانات
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is DashboardLoaded) {
          // جلب الإحصائيات الحقيقية من الحالة
          final stats = _getStatsForRole(state);

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: stats.length > 2 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 5,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return StatCard(
                title: stat.title,
                value: stat.value,
                icon: stat.icon,
                color: stat.color,
                trend: stat.trend,
                trendValue: stat.trendValue,
              );
            },
          );
        }

        return const SizedBox.shrink(); // حالة افتراضية
      },
    );
  }

  // تم تعديل هذه الدالة لتستقبل الحالة (State) كمصدر للبيانات
  List<StatData> _getStatsForRole(DashboardLoaded state) {
    switch (userRole) {
      case UserRole.superAdmin:
        return [
          StatData(
            title: 'Total Clients',
            value: state.totalClients.toString(), // <-- بيانات حقيقية
            icon: Icons.business,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+12%',
          ),
          StatData(
            title: 'Active Users',
            value: state.activeUsers.toString(), // <-- بيانات حقيقية
            icon: Icons.people,
            color: Colors.green,
            trend: TrendType.up,
            trendValue: '+8%',
          ),
          // ... يمكنك إضافة باقي البطاقات بنفس الطريقة
        ];

      case UserRole.cad:
        return [
          StatData(
            title: 'Total Employees',
            value: state.totalEmployees.toString(), // <-- بيانات حقيقية
            icon: Icons.group,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+3',
          ),
          StatData(
            title: 'Present Today',
            value: state.presentToday.toString(), // <-- بيانات حقيقية
            icon: Icons.check_circle,
            color: Colors.green,
            trend: TrendType.up,
            trendValue: '91%',
          ),
          StatData(
            title: 'Late Arrivals',
            value: state.lateArrivals.toString(), // <-- بيانات حقيقية
            icon: Icons.schedule,
            color: Colors.orange,
            trend: TrendType.down,
            trendValue: '-2',
          ),
          StatData(
            title: 'Absent Today',
            value: state.absentToday.toString(), // <-- بيانات حقيقية
            icon: Icons.cancel,
            color: Colors.red,
            trend: TrendType.up,
            trendValue: '+1',
          ),
        ];
      case UserRole.branchManager:
        return [
          StatData(
            title: 'Total Employees',
            value: state.totalEmployees.toString(), // <-- بيانات حقيقية
            icon: Icons.group,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+3',
          ),
          StatData(
            title: 'Present Today',
            value: state.presentToday.toString(), // <-- بيانات حقيقية
            icon: Icons.check_circle,
            color: Colors.green,
            trend: TrendType.up,
            trendValue: '91%',
          ),
          StatData(
            title: 'Late Arrivals',
            value: state.lateArrivals.toString(), // <-- بيانات حقيقية
            icon: Icons.schedule,
            color: Colors.orange,
            trend: TrendType.down,
            trendValue: '-2',
          ),
          StatData(
            title: 'Absent Today',
            value: state.absentToday.toString(), // <-- بيانات حقيقية
            icon: Icons.cancel,
            color: Colors.red,
            trend: TrendType.up,
            trendValue: '+1',
          ),
        ];

      case UserRole.employee:
        // إحصائيات الموظف قد تحتاج Cubit خاص بها أو تأتي من نفس Cubit الداشبورد
        return [
          StatData(
            title: 'Hours This Month',
            value: '168',
            icon: Icons.access_time,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+5h',
          ),
          StatData(
            title: 'Attendance Rate',
            value: '96%',
            icon: Icons.trending_up,
            color: Colors.green,
            trend: TrendType.stable,
            trendValue: '0%',
          ),
        ];
    }
  }
}

// باقي الكلاسات (StatCard, StatData, TrendType) تبقى كما هي
// ...
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final TrendType trend;
  final String trendValue;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              _buildTrendIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case TrendType.up:
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        break;
      case TrendType.down:
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        break;
      case TrendType.stable:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.grey;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trendIcon,
          size: 16,
          color: trendColor,
        ),
        const SizedBox(width: 4),
        Text(
          trendValue,
          style: TextStyle(
            fontSize: 12,
            color: trendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final TrendType trend;
  final String trendValue;

  StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendValue,
  });
}

enum TrendType { up, down, stable }

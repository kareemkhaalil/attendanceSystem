import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/enums/user_role.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardStats extends StatelessWidget {
  final UserRole userRole;

  const DashboardStats({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return const _StatsSkeleton();
        }

        if (state is DashboardError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('Error: ${state.message}',
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          final stats = _getStatsForRole(state);
          final width = MediaQuery.of(context).size.width;
          int columns = 2;
          if (width >= 1200 && stats.length >= 4)
            columns = 4;
          else if (width >= 900 && stats.length >= 3) columns = 3;

          final ratio = width >= 1200
              ? 2.8
              : width >= 900
                  ? 2.6
                  : 2.1;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: ratio,
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

        return const SizedBox.shrink();
      },
    );
  }

  List<StatData> _getStatsForRole(DashboardLoaded state) {
    switch (userRole) {
      case UserRole.superAdmin:
        return [
          StatData(
            title: 'Total Clients',
            value: state.totalClients.toString(),
            icon: Icons.business,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+12%',
          ),
          StatData(
            title: 'Active Users',
            value: state.activeUsers.toString(),
            icon: Icons.people,
            color: Colors.green,
            trend: TrendType.up,
            trendValue: '+8%',
          ),
          // زوّد بطاقات تانية لو عايز
        ];

      case UserRole.cad:
        return [
          StatData(
            title: 'Total Employees',
            value: state.totalEmployees.toString(),
            icon: Icons.group,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+3',
          ),
          StatData(
            title: 'Present Today',
            value: state.presentToday.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            trend: TrendType.up,
            trendValue: '91%',
          ),
          StatData(
            title: 'Late Arrivals',
            value: state.lateArrivals.toString(),
            icon: Icons.schedule,
            color: Colors.orange,
            trend: TrendType.down,
            trendValue: '-2',
          ),
          StatData(
            title: 'Absent Today',
            value: state.absentToday.toString(),
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
            value: state.totalEmployees.toString(),
            icon: Icons.group,
            color: Colors.blue,
            trend: TrendType.up,
            trendValue: '+3',
          ),
          StatData(
            title: 'Present Today',
            value: state.presentToday.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            trend: TrendType.up,
            trendValue: '91%',
          ),
          StatData(
            title: 'Late Arrivals',
            value: state.lateArrivals.toString(),
            icon: Icons.schedule,
            color: Colors.orange,
            trend: TrendType.down,
            trendValue: '-2',
          ),
          StatData(
            title: 'Absent Today',
            value: state.absentToday.toString(),
            icon: Icons.cancel,
            color: Colors.red,
            trend: TrendType.up,
            trendValue: '+1',
          ),
        ];

      case UserRole.employee:
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.textTheme.bodyLarge?.color;
    final subtle = theme.textTheme.bodySmall?.color ??
        (isDark ? Colors.white54 : Colors.black54);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // لمسة خلفية خفيفة من لون البطاقة
          Positioned(
            right: -8,
            top: -8,
            child: Icon(icon, size: 96, color: color.withOpacity(0.08)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة داخل دائرة متدرجة
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.25), color.withOpacity(0.55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: isDark ? Colors.white : Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // السطر العلوي: الترند
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: subtle, fontWeight: FontWeight.w600)),
                        _TrendBadge(trend: trend, value: trendValue),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // القيمة الكبيرة
                    Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // شريط ديكوري بسيط بنفس اللون
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 1,
                        minHeight: 5,
                        valueColor: AlwaysStoppedAnimation(
                            color.withOpacity(isDark ? 0.9 : 0.8)),
                        backgroundColor: color.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final TrendType trend;
  final String value;

  const _TrendBadge({required this.trend, required this.value});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (trend) {
      case TrendType.up:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case TrendType.down:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case TrendType.stable:
        icon = Icons.trending_flat;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor.withOpacity(0.18);

    Widget box() => Container(
          height: 86,
          decoration: BoxDecoration(
            color: base.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
          ),
        );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2),
      itemBuilder: (_, __) => box(),
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

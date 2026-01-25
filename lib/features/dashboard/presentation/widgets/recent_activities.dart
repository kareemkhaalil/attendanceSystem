import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/features/dashboard/domain/entities/activity_entity.dart';
import 'package:manzoma/features/dashboard/presentation/cubit/activite_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentActivities extends StatelessWidget {
  final UserRole userRole;

  const RecentActivities({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ... box shadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
              // ... header
              ),
          const SizedBox(height: 16),
          BlocBuilder<ActivityCubit, ActivityState>(
            builder: (context, state) {
              if (state is ActivityLoading || state is ActivityInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ActivityError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is ActivityLoaded) {
                if (state.activities.isEmpty) {
                  return const Center(child: Text('No recent activities.'));
                }
                // بناء القائمة من البيانات الحقيقية
                return Column(
                  children: state.activities
                      .map((activity) => _buildActivityItem(activity))
                      .toList(),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // هذه الدالة الآن تستقبل ActivityEntity
  Widget _buildActivityItem(ActivityEntity activity) {
    // دالة مساعدة لتحديد الأيقونة واللون بناءً على نوع النشاط
    final activityVisuals = _getActivityVisuals(activity.actionType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activityVisuals.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activityVisuals.icon,
              color: activityVisuals.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // استخدام مكتبة timeago لعرض الوقت
          Text(
            timeago.format(activity.time),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لربط نوع النشاط بالأيقونة واللون
  ({IconData icon, Color color}) _getActivityVisuals(String actionType) {
    switch (actionType) {
      case 'CREATE_CLIENT':
        return (icon: Icons.business, color: Colors.blue);
      case 'CREATE_USER':
        return (icon: Icons.person_add, color: Colors.purple);
      case 'CHECK_IN':
        return (icon: Icons.login, color: Colors.green);
      default:
        return (icon: Icons.notifications, color: Colors.grey);
    }
  }
}

// لم نعد بحاجة لكلاس ActivityData القديم

class ActivityData {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  ActivityData({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  });
}

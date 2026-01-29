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
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Recent Activities',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Icon(Icons.notifications_active_outlined,
                    size: 20, color: theme.dividerColor),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                if (state is ActivityLoading || state is ActivityInitial) {
                  return const _ActivitiesSkeleton();
                }

                if (state is ActivityError) {
                  return _ErrorState(message: state.message);
                }

                if (state is ActivityLoaded) {
                  if (state.activities.isEmpty) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('No recent activities.'),
                    ));
                  }

                  return Column(
                    children: state.activities
                        .map((a) => _ActivityTile(activity: a))
                        .toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityEntity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final visuals = _getActivityVisuals(activity.actionType);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة داخل حاوية + شريط زمني بسيط
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: visuals.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: visuals.color.withOpacity(0.25)),
                ),
                child: Icon(visuals.icon, color: visuals.color, size: 22),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // المحتوى
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.title,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(activity.description,
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeago.format(activity.time),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

class _ActivitiesSkeleton extends StatelessWidget {
  const _ActivitiesSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.dividerColor.withOpacity(0.18);

    Widget line({double h = 12, double w = 120}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: base.withOpacity(0.35),
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return Column(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: base.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: base.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      line(w: 160),
                      const SizedBox(height: 8),
                      line(w: 220),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text('Error: $message', style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

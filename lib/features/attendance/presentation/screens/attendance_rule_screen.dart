import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/core/theme/app_themes.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_rule_entity.dart';
import 'package:manzoma/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:manzoma/features/attendance/presentation/cubit/attendance_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';

class AttendanceRulesPage extends StatelessWidget {
  const AttendanceRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SharedPrefHelper.getUser();

    return BlocProvider(
      create: (_) => AttendanceCubit()..loadRules(user!.tenantId),
      child: const _AttendanceRulesView(),
    );
  }
}

class _AttendanceRulesView extends StatelessWidget {
  const _AttendanceRulesView();

  @override
  Widget build(BuildContext context) {
    final user = SharedPrefHelper.getUser();

    final g = Theme.of(context).extension<GlassTheme>()!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text("قواعد الحضور",
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: g.onGlassPrimary)),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: g.onGlassPrimary),
              onPressed: () =>
                  context.read<AttendanceCubit>().loadRules(user!.tenantId),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            const _BackgroundLayer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  if (state is AttendanceRulesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AttendanceRulesError) {
                    return Center(child: Text(state.message));
                  } else if (state is AttendanceRulesLoaded) {
                    if (state.rules.isEmpty) {
                      return Center(
                        child: Text("لا توجد قواعد حتى الآن",
                            style: TextStyle(color: g.onGlassSecondary)),
                      );
                    }
                    return _RulesTable(user, rules: state.rules);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _GradientButton(
          text: "إضافة قاعدة جديدة",
          icon: Icons.add_rounded,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const AddAttendanceRuleDialog(),
            );
          },
        ),
      ),
    );
  }
}

/* =========================
   جدول القواعد
   ========================= */
class _RulesTable extends StatelessWidget {
  final List<AttendanceRuleEntity> rules;
  final user;

  const _RulesTable(this.user, {required this.rules});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: g.glass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: g.glassBorder),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text("اسم القاعدة")),
                DataColumn(label: Text("وقت البداية")),
                DataColumn(label: Text("وقت النهاية")),
                DataColumn(label: Text("الأيام")),
                DataColumn(label: Text("إجراءات")),
              ],
              rows: rules.map((rule) {
                final days = (rule.details["work_days"] as List<dynamic>)
                    .map((e) => e.toString())
                    .join("، ");

                return DataRow(cells: [
                  DataCell(Text(rule.name ?? "-")),
                  DataCell(Text(rule.details["start_time"])),
                  DataCell(Text(rule.details["end_time"])),
                  DataCell(Text(days)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddAttendanceRuleDialog(
                            rule: rule,
                            user: user,
                          ),
                        );
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   خلفية مودرن (زي الحضور)
   ========================= */
class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [g.bgStart, g.bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
            top: -60, right: -30, child: _Blob(color: g.blob1, size: 200)),
        Positioned(
            top: 120, left: -40, child: _Blob(color: g.blob2, size: 180)),
        Positioned(
            bottom: -40, right: -20, child: _Blob(color: g.blob3, size: 160)),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}

/* =========================
   زر Gradient
   ========================= */
class _GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [g.accent, Theme.of(context).colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: g.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class AddAttendanceRuleDialog extends StatefulWidget {
  final AttendanceRuleEntity? rule; // لو هنعدل
  final user;

  const AddAttendanceRuleDialog({super.key, this.rule, this.user});

  @override
  State<AddAttendanceRuleDialog> createState() =>
      _AddAttendanceRuleDialogState();
}

class _AddAttendanceRuleDialogState extends State<AddAttendanceRuleDialog> {
  final nameCtrl = TextEditingController();
  TimeOfDay? start;
  TimeOfDay? end;
  final Set<String> selectedDays = {};

  @override
  void initState() {
    super.initState();
    if (widget.rule != null) {
      nameCtrl.text = widget.rule!.name ?? "";
      start = _parseTime(widget.rule!.details["start_time"] ?? "");
      end = _parseTime(widget.rule!.details["end_time"] ?? "");
      selectedDays.addAll((widget.rule!.details["work_days"] as List<dynamic>?)
              ?.map((e) => e.toString()) ??
          []);
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;

    return AlertDialog(
      title: Text(widget.rule == null ? "إضافة قاعدة جديدة" : "تعديل القاعدة"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "اسم القاعدة"),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                child: Text(
                    start == null ? "وقت البداية" : start!.format(context)),
                onPressed: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (picked != null) setState(() => start = picked);
                },
              ),
              const Spacer(),
              TextButton(
                child: Text(end == null ? "وقت النهاية" : end!.format(context)),
                onPressed: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (picked != null) setState(() => end = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children:
                ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"].map((d) {
              return FilterChip(
                label: Text(d),
                selected: selectedDays.contains(d),
                onSelected: (v) {
                  setState(() {
                    v ? selectedDays.add(d) : selectedDays.remove(d);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameCtrl.text.isEmpty || start == null || end == null) return;

            final tenantId = SharedPrefHelper.getUser()!.tenantId;
            final newRule = AttendanceRuleEntity(
              id: widget.rule?.id ?? "", // لو تعديل
              tenantId: tenantId,
              name: nameCtrl.text,

              details: {
                "start_time": "${start!.hour}:${start!.minute}",
                "end_time": "${end!.hour}:${end!.minute}",
                "work_days": selectedDays.toList(),
                "allow_late_minutes": 15,
              },
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final cubit = context.read<AttendanceCubit>();
            if (widget.rule == null) {
              cubit.addRule(newRule);
            } else {
              cubit.updateRule(newRule);
            }

            Navigator.pop(context);
          },
          child: const Text("حفظ"),
        ),
      ],
    );
  }
}

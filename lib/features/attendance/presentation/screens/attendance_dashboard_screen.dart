import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/features/attendance/data/models/attendance_model.dart';
import 'package:manzoma/features/attendance/domain/entities/attendance_entity.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:manzoma/core/theme/app_themes.dart';
import '../cubit/attendance_cubit.dart';
import '../cubit/attendance_state.dart';

class AttendanceDashboardPage extends StatefulWidget {
  const AttendanceDashboardPage({super.key});

  @override
  State<AttendanceDashboardPage> createState() =>
      _AttendanceDashboardPageState();
}

class _AttendanceDashboardPageState extends State<AttendanceDashboardPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final String _selectedRange = 'اليوم'; // اليوم - هذا الأسبوع - هذا الشهر
  final bool _showOnlyInside = false; // فلتر سريع للحالة

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لو AttendanceCubit متوفر بالفعل أعلى الشجرة، احذف BlocProvider اللي تحت.
    return BlocProvider<AttendanceCubit>(
      create: (_) => AttendanceCubit()..refreshCurrentUserHistory(),
      child: const _AttendanceDashboardView(),
    );
  }
}

class _AttendanceDashboardView extends StatefulWidget {
  const _AttendanceDashboardView();

  @override
  State<_AttendanceDashboardView> createState() =>
      _AttendanceDashboardViewState();
}

class _AttendanceDashboardViewState extends State<_AttendanceDashboardView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedRange = 'اليوم';
  bool _showOnlyInside = false;

  final user = SharedPrefHelper.getUser();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            "لوحة متابعة الحضور",
            style:
                TextStyle(fontWeight: FontWeight.w700, color: g.onGlassPrimary),
          ),
          actions: [
            IconButton(
                tooltip: 'تحديث',
                icon: Icon(Icons.refresh, color: g.onGlassPrimary),
                onPressed: () {
                  print('screen tenant id : ${user?.tenantId}');
                  context.read<AttendanceCubit>().refreshCurrentUserHistory();
                }),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            const _BackgroundLayer(),
            RefreshIndicator(
              onRefresh: () =>
                  context.read<AttendanceCubit>().refreshCurrentUserHistory(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  const SliverToBoxAdapter(
                      child: SizedBox(height: kToolbarHeight + 24)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _HeaderCard(
                          onCreateQrTap: () =>
                              _showCreateQrBottomSheet(context)),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _StatGrid(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FilterBar(
                        searchCtrl: _searchCtrl,
                        selectedRange: _selectedRange,
                        showOnlyInside: _showOnlyInside,
                        onRangeChange: (val) =>
                            setState(() => _selectedRange = val),
                        onStatusToggle: (val) =>
                            setState(() => _showOnlyInside = val),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _AttendanceSection(
                        searchCtrl: _searchCtrl,
                        showOnlyInside: _showOnlyInside,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateQrBottomSheet(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(
                color: g.glass,
                border: Border.all(color: g.glassBorder),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2, size: 64, color: g.accent),
                  const SizedBox(height: 8),
                  Text("إنشاء جلسة حضور عبر QR",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: g.onGlassPrimary)),
                  const SizedBox(height: 8),
                  Text(
                      "سيتم إنشاء جلسة حضور جديدة، وسيظهر كود QR للموظفين لمسحه.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: g.onGlassSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientButton(
                          text: "إلغاء",
                          onTap: () => Navigator.pop(context),
                          gradient: LinearGradient(colors: [
                            g.onGlassSecondary.withOpacity(0.6),
                            g.onGlassSecondary.withOpacity(0.8),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientButton(
                          text: "إنشاء الجلسة",
                          icon: Icons.play_arrow_rounded,
                          onTap: () {
                            Navigator.pop(context);
                            context.read<AttendanceCubit>().startQrSession();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) {
                                return BlocProvider.value(
                                  value: context.read<AttendanceCubit>(),
                                  child: const _QrSessionDialog(),
                                );
                              },
                            );
                          },
                          gradient: LinearGradient(
                            colors: [
                              g.accent.withOpacity(0.9),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =========================
   خلفية مودرن بلمسات متدرجة
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
   الهيدر + زر إنشاء جلسة QR
   ========================= */
class _HeaderCard extends StatelessWidget {
  final VoidCallback onCreateQrTap;

  const _HeaderCard({required this.onCreateQrTap});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    final date = DateTime.now().toLocal().toString().split(' ').first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: g.glass,
            border: Border.all(color: g.glassBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("مرحباً 👋",
                        style:
                            TextStyle(fontSize: 14, color: g.onGlassSecondary)),
                    const SizedBox(height: 6),
                    Text("تابع حضور فريقك بسهولة",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: g.onGlassPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16, color: g.onGlassSecondary),
                        const SizedBox(width: 6),
                        Text("تاريخ اليوم: $date",
                            style: TextStyle(color: g.onGlassSecondary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: 0.72,
                          minHeight: 6,
                          backgroundColor: g.glassBorder,
                          valueColor: AlwaysStoppedAnimation(g.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("معدل الالتزام هذا الشهر: 72%",
                        style:
                            TextStyle(color: g.onGlassSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientButton(
                  text: "إنشاء جلسة حضور بالـ QR",
                  icon: Icons.qr_code_2,
                  onTap: onCreateQrTap,
                  gradient: LinearGradient(
                    colors: [g.accent, Theme.of(context).colorScheme.secondary],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateQrBottomSheet(BuildContext pageContext) {
    final g = Theme.of(pageContext).extension<GlassTheme>()!;
    showModalBottomSheet(
      context: pageContext,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(
                color: g.glass,
                border: Border.all(color: g.glassBorder),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2, size: 64, color: g.accent),
                  const SizedBox(height: 8),
                  Text("إنشاء جلسة حضور عبر QR",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: g.onGlassPrimary)),
                  const SizedBox(height: 8),
                  Text(
                      "سيتم إنشاء جلسة حضور جديدة، وسيظهر كود QR للموظفين لمسحه.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: g.onGlassSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientButton(
                          text: "إلغاء",
                          onTap: () => Navigator.pop(sheetContext),
                          gradient: LinearGradient(
                            colors: [
                              g.onGlassSecondary.withOpacity(0.6),
                              g.onGlassSecondary.withOpacity(0.8)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientButton(
                          text: "إنشاء الجلسة",
                          icon: Icons.play_arrow_rounded,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            final cubit = sheetContext.read<AttendanceCubit>();
                            cubit.startQrSession();

                            showDialog(
                              context: sheetContext,
                              barrierDismissible: false,
                              useRootNavigator: false, // مهم
                              builder: (ctx) {
                                return BlocProvider.value(
                                  value: sheetContext.read<AttendanceCubit>(),
                                  child: const _QrSessionDialog(),
                                );
                              },
                            );
                          },
                          gradient: LinearGradient(
                            colors: [
                              g.accent.withOpacity(0.9),
                              Theme.of(pageContext)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.9)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =========================
   بطاقات الإحصائيات (Grid)
   ========================= */
class _StatGrid extends StatelessWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        title: "عدد الموظفين",
        value: "120",
        icon: Icons.people_alt_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
      ),
      _StatItem(
        title: "جلسات اليوم",
        value: "8",
        icon: Icons.access_time_filled_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFF34D399), Color(0xFF10B981)]),
      ),
      _StatItem(
        title: "المتأخرين",
        value: "4",
        icon: Icons.warning_amber_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEA580C)]),
      ),
      _StatItem(
        title: "إجمالي الجلسات",
        value: "52",
        icon: Icons.event_available_rounded,
        gradient: const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)]),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 2;
        if (width >= 1100)
          columns = 4;
        else if (width >= 820) columns = 3;

        const spacing = 12.0;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map((e) => SizedBox(width: itemWidth, child: _StatCard(item: e)))
              .toList(),
        );
      },
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  _StatItem(
      {required this.title,
      required this.value,
      required this.icon,
      required this.gradient});
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: item.gradient,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              right: -12,
              top: -12,
              child: Icon(item.icon,
                  size: 90, color: Colors.white.withOpacity(0.15))),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Icon(item.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.value,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(item.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   شريط الفلاتر + البحث
   ========================= */
class _FilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String selectedRange;
  final bool showOnlyInside;
  final ValueChanged<String> onRangeChange;
  final ValueChanged<bool> onStatusToggle;

  const _FilterBar({
    required this.searchCtrl,
    required this.selectedRange,
    required this.showOnlyInside,
    required this.onRangeChange,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    const ranges = ["اليوم", "هذا الأسبوع", "هذا الشهر"];
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: g.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: g.glassBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.search, color: g.onGlassSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: "ابحث بالاسم أو المعرف...",
                      hintStyle: TextStyle(color: g.onGlassSecondary),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: g.onGlassPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          spacing: 6,
          children: [
            for (final r in ranges)
              ChoiceChip(
                label: Text(r),
                selected: selectedRange == r,
                onSelected: (_) => onRangeChange(r),
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: g.glass,
                labelStyle: TextStyle(
                    color:
                        selectedRange == r ? Colors.white : g.onGlassSecondary),
                shape: StadiumBorder(side: BorderSide(color: g.glassBorder)),
              ),
            FilterChip(
              label: const Text("داخل فقط"),
              selected: showOnlyInside,
              onSelected: (v) => onStatusToggle(v),
              selectedColor: Colors.teal,
              backgroundColor: g.glass,
              labelStyle: TextStyle(
                  color: showOnlyInside ? Colors.white : g.onGlassSecondary),
              shape: StadiumBorder(side: BorderSide(color: g.glassBorder)),
            ),
          ],
        ),
      ],
    );
  }
}

/* =========================
   قسم سجل الحضور (Bloc)
   ========================= */
class _AttendanceSection extends StatelessWidget {
  final TextEditingController searchCtrl;
  final bool showOnlyInside;

  const _AttendanceSection({
    required this.searchCtrl,
    required this.showOnlyInside,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: g.glass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: g.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: "سجل الحضور"),
              const SizedBox(height: 8),
              BlocBuilder<AttendanceCubit, AttendanceState>(
                buildWhen: (prev, curr) =>
                    curr is AttendanceInitial ||
                    curr is AttendanceLoading ||
                    curr is AttendanceError ||
                    curr is AttendanceHistoryLoaded ||
                    curr is AttendanceCheckInSuccess ||
                    curr is AttendanceCheckOutSuccess,
                builder: (context, state) {
                  if (state is AttendanceLoading ||
                      state is AttendanceInitial) {
                    return const _SkeletonTable();
                  } else if (state is AttendanceError) {
                    return _ErrorState(message: state.message);
                  } else if (state is AttendanceHistoryLoaded) {
                    List<AttendanceEntity> list =
                        List<AttendanceEntity>.from(state.attendanceList);
                    final q = searchCtrl.text.trim();
                    if (q.isNotEmpty) {
                      list = list.where((AttendanceEntity a) {
                        final uid = (a.userId ?? '').toLowerCase();
                        return uid.contains(q.toLowerCase());
                      }).toList();
                    }
                    if (showOnlyInside) {
                      list = list
                          .where((AttendanceEntity a) => a.checkOutTime == null)
                          .toList();
                    }

                    if (list.isEmpty) return const _EmptyState();
                    // مرّر List<AttendanceEntity> للجدول
                    return _AttendanceTable(attendanceList: list);
                  }
                  return const _SkeletonTable();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: g.onGlassPrimary)),
        const Spacer(),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text("عرض الكل"),
          style: TextButton.styleFrom(foregroundColor: g.onGlassSecondary),
        ),
      ],
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  final List<AttendanceEntity> attendanceList;

  const _AttendanceTable({required this.attendanceList});

  String _formatTime(DateTime? dt) {
    if (dt == null) return "-";
    final t = dt.toLocal().toString().split(' ')[1];
    return t.substring(0, 5); // hh:mm
  }

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    final headingColor = g.glass.withOpacity(0.6);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: g.glassBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTableTheme(
          data: DataTableThemeData(
            headingRowColor: WidgetStatePropertyAll(headingColor),
            headingTextStyle:
                TextStyle(fontWeight: FontWeight.w700, color: g.onGlassPrimary),
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return g.glass.withOpacity(0.5);
              }
              return Colors.transparent;
            }),
            dividerThickness: 0.6,
            horizontalMargin: 16,
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // ← عرض الشاشة
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("الموظف")),
                  DataColumn(label: Text("الحضور")),
                  DataColumn(label: Text("الانصراف")),
                  DataColumn(label: Text("الحالة")),
                ],
                rows: attendanceList.map((attendance) {
                  final inside = attendance.checkOutTime == null;
                  return DataRow(cells: [
                    DataCell(Text(attendance.userName ?? "-")),
                    DataCell(Text(_formatTime(attendance.checkInTime))),
                    DataCell(Text(_formatTime(attendance.checkOutTime))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: inside ? g.statusInBg : g.statusOutBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: g.glassBorder),
                      ),
                      child: Text(
                        inside ? "داخل" : "خارج",
                        style: TextStyle(
                            color: inside ? g.statusInFg : g.statusOutFg,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   حالات العرض: فارغ / خطأ / سكلتون
   ========================= */
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Container(
      height: 140,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: g.onGlassSecondary),
          const SizedBox(height: 8),
          Text("لا توجد بيانات حضور مسجلة",
              style: TextStyle(color: g.onGlassSecondary)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: g.statusOutBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: g.glassBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: g.statusOutFg),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message, style: TextStyle(color: g.onGlassPrimary))),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () =>
                context.read<AttendanceCubit>().refreshCurrentUserHistory(),
            child: Text("إعادة المحاولة",
                style: TextStyle(color: g.onGlassSecondary)),
          ),
        ],
      ),
    );
  }
}

class _SkeletonTable extends StatelessWidget {
  const _SkeletonTable();

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    Widget bar({double w = 80}) => Container(
          width: w,
          height: 14,
          decoration: BoxDecoration(
              color: g.glassBorder, borderRadius: BorderRadius.circular(6)),
        );

    return Column(
      children: List.generate(6, (i) {
        return Container(
          margin: EdgeInsets.only(bottom: i == 5 ? 0 : 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
              color: g.glass.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              bar(w: 140),
              const Spacer(),
              bar(w: 60),
              const SizedBox(width: 24),
              bar(w: 60),
              const SizedBox(width: 24),
              bar(w: 56),
            ],
          ),
        );
      }),
    );
  }
}

/* =========================
   زر متدرّج قابل لإعادة الاستخدام
   ========================= */
class _GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final Gradient? gradient;

  const _GradientButton({
    required this.text,
    this.icon,
    required this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    final gr = gradient ??
        LinearGradient(
          colors: [g.accent, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 52,
        decoration: BoxDecoration(
          gradient: gr,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: g.glassBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
              ],
              Text(
                text, // بدل الثابت
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   Dialog: يعرض حالة جلسة الـ QR من الكيوبت
   ========================= */
class _QrSessionDialog extends StatelessWidget {
  const _QrSessionDialog();

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: g.glass,
              border: Border.all(color: g.glassBorder),
              borderRadius: BorderRadius.circular(18),
            ),
            child: BlocConsumer<AttendanceCubit, AttendanceState>(
              listenWhen: (prev, curr) =>
                  curr is AttendanceQrExpired || curr is AttendanceQrError,
              listener: (context, state) {
                if (state is AttendanceQrExpired) {
                  Navigator.of(context).maybePop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('انتهت صلاحية الجلسة')),
                    );
                  });
                } else if (state is AttendanceQrError) {
                  Navigator.of(context).maybePop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  });
                }
              },
              // ✅ عدلنا buildWhen علشان يسمح بإعادة البناء حتى مع نفس النوع Active
              buildWhen: (prev, curr) {
                if (curr is AttendanceQrActive && prev is AttendanceQrActive) {
                  return curr.qrText != prev.qrText ||
                      curr.remainingSeconds != prev.remainingSeconds;
                }
                return true;
              },
              builder: (context, state) {
                print('[QR] builder fired with state = $state');
                print('[QR] cubit = ${context.read<AttendanceCubit>}');
                print('[QR] dialog builder state = $state');

                if (state is AttendanceQrCreating) {
                  print('[QR] creating session...');
                  return const SizedBox(
                    height: 260,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                } else if (state is AttendanceQrActive) {
                  print('[QR] dialog active, qrText=${state.qrText}');
                  final v = QrValidator.validate(
                    data: state.qrText,
                    version: QrVersions.auto,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  );
                  print('[QR] validation = ${v.status}');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'جلسة QR نشطة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: g.onGlassPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: state.qrText,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'يتغير في: ${state.remainingSeconds}s',
                        style: TextStyle(
                          color: g.onGlassSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _GradientButton(
                        text: "إنهاء الجلسة",
                        icon: Icons.stop_rounded,
                        onTap: () {
                          Navigator.of(context).maybePop();
                          context.read<AttendanceCubit>().endQrSession();
                        },
                      ),
                    ],
                  );
                } else if (state is AttendanceQrError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'حدث خطأ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: g.onGlassPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: g.onGlassSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _GradientButton(
                              text: "إغلاق",
                              onTap: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(),
                              gradient: LinearGradient(
                                colors: [
                                  g.onGlassSecondary.withOpacity(0.8),
                                  g.onGlassSecondary.withOpacity(0.9)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GradientButton(
                              text: "محاولة مجدداً",
                              onTap: () => context
                                  .read<AttendanceCubit>()
                                  .renewQrSession(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // 🟡 fallback محسن
                return SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      'Waiting for QR session...',
                      style: TextStyle(color: g.onGlassSecondary),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

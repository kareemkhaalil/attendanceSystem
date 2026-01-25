// lib/features/employee/presentation/screens/employee_home_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:manzoma/core/location/location_helper.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/core/utils/responsive.util.dart';
import 'package:manzoma/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:manzoma/features/attendance/presentation/cubit/attendance_state.dart';
import 'package:manzoma/features/employee/presentation/widgets/settings_menu.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen>
    with TickerProviderStateMixin {
  String _userName = "الموظف";
  late Timer _timer;
  DateTime _now = DateTime.now();
  Timer? _workTicker;
  DateTime? _checkInAt;
  final Duration _worked = Duration.zero;

  // Animations
  late AnimationController _ringCtrl; // دوران حلقة الزر
  late AnimationController _introCtrl; // دخول الصفحة
  late Animation<double> _introFade;
  late Animation<Offset> _headerSlide;
  late Animation<Offset> _contentSlide;

  int _currentIndex = 0;

  // بيانات الأسبوع (نفسها)
  final List<double> _weekData = [0.8, 0.6, 0.9, 0.4, 0.7, 0.5, 0.85];
  final List<String> _weekDays = ["S", "M", "T", "W", "T", "F", "S"];

  // أكشنز سريعة (كبسولات)
  final List<Map<String, dynamic>> _quickActions = const [
    {
      'icon': Icons.insert_chart_outlined,
      'title': 'إحصاءات',
      'color': Color(0xFF7C3AED)
    },
    {
      'icon': Icons.history_outlined,
      'title': 'سجل الحضور',
      'color': Color(0xFF0EA5E9)
    },
    {
      'icon': Icons.person_outline,
      'title': 'حسابي',
      'color': Color(0xFFEF4444)
    },
    {
      'icon': Icons.help_outline,
      'title': 'المساعدة',
      'color': Color(0xFFF59E0B)
    },
  ];

  // Bottom nav
  final List<Map<String, dynamic>> _navItems = const [
    {
      "icon": Icons.home_outlined,
      "activeIcon": Icons.home,
      "label": "الرئيسية"
    },
    {
      "icon": Icons.schedule_outlined,
      "activeIcon": Icons.schedule,
      "label": "الحضور"
    },
    {
      "icon": Icons.insert_chart_outlined,
      "activeIcon": Icons.insert_chart,
      "label": "التقارير"
    },
    {
      "icon": Icons.person_outline,
      "activeIcon": Icons.person,
      "label": "حسابي"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // تحديث الساعة
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _now = DateTime.now());
    });

    // دوران حلقة الزر
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // أنيميشن دخول
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _introFade =
        CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic);
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _introCtrl,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _introCtrl,
                curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)));
  }

  @override
  void dispose() {
    _timer.cancel();
    _ringCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = SharedPrefHelper.getUser();
    if (user != null) {
      setState(() => _userName = user.name ?? "الموظف");
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = ResponsiveUtils.getResponsivePaddingAll(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      extendBody: true,
      body: SafeArea(
        child: BlocConsumer<AttendanceCubit, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceCheckInSuccess) {
              _showCustomDialog("تم تسجيل الحضور بنجاح",
                  color: const Color(0xFF10B981));
            } else if (state is AttendanceCheckOutSuccess) {
              _showCustomDialog("تم تسجيل الانصراف بنجاح",
                  color: const Color(0xFFF59E0B));
            } else if (state is AttendanceError) {
              _showCustomDialog(state.message, color: Colors.red);
            }
          },
          builder: (context, state) {
            final isCheckedIn = state is AttendanceCheckInSuccess;
            final isLoading = state is AttendanceLoading;

            return Stack(
              children: [
                // المحتوى
                FadeTransition(
                  opacity: _introFade,
                  child: SingleChildScrollView(
                    padding: pad.copyWith(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // هيدر Aurora منحني
                        SlideTransition(
                          position: _headerSlide,
                          child: _AuroraHeader(
                            isCheckedIn: isCheckedIn,
                            userName: _userName,
                            now: _now,
                            onSettingsTap: () => _showSettingsMenu(context),
                          ),
                        ),

                        // زر الحضور/الانصراف - يطفو أسفل الهيدر
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: Center(
                            child: _NeonCheckButton(
                              isCheckedIn: isCheckedIn,
                              ringCtrl: _ringCtrl,
                              onTap: () =>
                                  _handleAttendanceAction(context, state),
                            ),
                          ),
                        ),

                        // أكشنز سريعة (Pills)
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: SlideTransition(
                            position: _contentSlide,
                            child: _ActionPillsRow(
                              actions: _quickActions,
                              onTap: (title) {
                                HapticFeedback.selectionClick();
                                _handleQuickAction(title);
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: isTablet ? 28 : 5),

                        // كارت الأداء بسِباركلاين
                        SlideTransition(
                          position: _contentSlide,
                          child: _SparklineCard(
                            title: "ملخص الأسبوع",
                            data: _weekData,
                            labels: _weekDays,
                            accent: isCheckedIn
                                ? const Color(0xFF10B981)
                                : const Color(0xFF7C3AED),
                            onViewAll: () {
                              try {
                                GoRouter.of(context).go('/reports');
                              } catch (_) {}
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation حديث
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16 + MediaQuery.of(context).padding.bottom * 0.4,
                  child: _PillBottomNav(
                    items: _navItems,
                    currentIndex: _currentIndex,
                    onTap: (i) {
                      setState(() => _currentIndex = i);
                      _handleNavigationTap(i);
                    },
                  ),
                ),

                // Loading Overlay أنيق
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: false,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.12),
                          child: const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= Actions =================
  Future<void> _handleAttendanceAction(BuildContext context, AttendanceState state) async {
    final cubit = context.read<AttendanceCubit>();
    final user = SharedPrefHelper.getUser();

    if (user == null) {
      _showCustomDialog("لم يتم العثور على بيانات المستخدم", color: Colors.red);
      return;
    }

    HapticFeedback.lightImpact();

    if (state is AttendanceCheckInSuccess) {
      cubit.checkOut(attendanceId: state.attendance.id);
    } else {
      // Get current location for check-in
      String location = "";
      try {
        final position = await LocationHelper.getCurrentLocation();
        location = "${position.latitude},${position.longitude}";
      } catch (e) {
        _showCustomDialog("تعذر الحصول على الموقع: $e", color: Colors.orange);
      }
      cubit.checkIn(userId: user.id, location: location);
    }
  }

  void _handleQuickAction(String title) {
    _showCustomDialog("تم النقر على: $title", color: const Color(0xFF4F46E5));
  }

  void _showCustomDialog(String message, {Color? color}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: color ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }

  void _handleNavigationTap(int index) {
    if (index == 1) {
      GoRouter.of(context).go('/employee/attendance');
    } else if (index == 2) {
      GoRouter.of(context).go('/reports');
    } else if (index == 3) {
      GoRouter.of(context).go('/profile');
    }
  }

  void _showSettingsMenu(BuildContext context) {
    SettingsMenu.show(
      context,
      onSettingsTap: () => Navigator.pop(context),
      onLogoutTap: () {
        Navigator.pop(context);
        GoRouter.of(context).go('/login');
      },
    );
  }
}

// ================= Pieces =================

class _AuroraHeader extends StatelessWidget {
  final bool isCheckedIn;
  final String userName;
  final DateTime now;
  final VoidCallback onSettingsTap;

  const _AuroraHeader({
    required this.isCheckedIn,
    required this.userName,
    required this.now,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final greet = _greeting(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final List<Color> gradient = isCheckedIn
        ? const [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF60A5FA)]
        : const [Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFF0EA5E9)];

    final height = MediaQuery.of(context).size.height * 0.28; // 28% من الارتفاع

    return ClipPath(
      clipper: _CurvedClipper(),
      child: Container(
        height: height.clamp(220, 320),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // لمسات دوائر شفافة
            Positioned(
              top: -40,
              right: -20,
              child: _softCircle(160, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: _softCircle(120, Colors.white.withValues(alpha: 0.06)),
            ),

            // المحتوى
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف أعلى
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onSettingsTap,
                        icon: const Icon(Icons.settings_rounded,
                            color: Colors.white),
                        tooltip: 'الإعدادات',
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "$greet، ",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.white.withValues(alpha: .9)),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .95),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softCircle(double size, Color color) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return "صباح الخير";
    if (h < 17) return "مساء الخير";
    return "مساء النور";
  }
}

class _CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 40);
    p.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height - 40);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_CurvedClipper oldClipper) => false;
}

class _NeonCheckButton extends StatelessWidget {
  final bool isCheckedIn;
  final AnimationController ringCtrl;
  final VoidCallback onTap;

  const _NeonCheckButton({
    required this.isCheckedIn,
    required this.ringCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base =
        isCheckedIn ? const Color(0xFF10B981) : const Color(0xFF7C3AED);
    final sec = isCheckedIn ? const Color(0xFF34D399) : const Color(0xFF0EA5E9);

    final width = MediaQuery.of(context).size.width;
    final size = math.min(width * 0.58, 220.0);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // حلقة متوهجة تدور
          AnimatedBuilder(
            animation: ringCtrl,
            builder: (_, __) {
              return Transform.rotate(
                angle: ringCtrl.value * math.pi * 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [base, sec, base],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: base.withValues(alpha: .35),
                          blurRadius: 28,
                          spreadRadius: 1),
                    ],
                  ),
                ),
              );
            },
          ),
          // مركز الزر
          Container(
            width: size - 18,
            height: size - 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 18,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                      size: size * 0.22, color: base),
                  const SizedBox(height: 6),
                  Text(
                    isCheckedIn ? "انصراف" : "حضور",
                    style: TextStyle(
                      color: base,
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPillsRow extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final void Function(String title) onTap;

  const _ActionPillsRow({required this.actions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 170,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            childAspectRatio: 2,
            mainAxisSpacing: 4,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          itemBuilder: (_, i) {
            final item = actions[i];
            final color = item['color'] as Color;
            final icon = item['icon'] as IconData;
            final title = item['title'] as String;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(title),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: .12), color.withValues(alpha: .06)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: color.withValues(alpha: .2)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
        // ListView.separated(
        //   padding: const EdgeInsets.symmetric(horizontal: 8),
        //   scrollDirection: Axis.vertical,
        //   itemBuilder: (_, i) {
        //     final item = actions[i];
        //     final color = item['color'] as Color;
        //     final icon = item['icon'] as IconData;
        //     final title = item['title'] as String;

        //     return Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 6),
        //       child: InkWell(
        //         borderRadius: BorderRadius.circular(18),
        //         onTap: () => onTap(title),
        //         child: Container(
        //           width: 160,
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(18),
        //             gradient: LinearGradient(
        //               colors: [color.withValues(alpha: .12), color.withValues(alpha: .06)],
        //               begin: Alignment.topLeft,
        //               end: Alignment.bottomRight,
        //             ),
        //             border: Border.all(color: color.withValues(alpha: .2)),
        //           ),
        //           padding:
        //               const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        //           child: Row(
        //             children: [
        //               Container(
        //                 width: 44,
        //                 height: 44,
        //                 decoration: BoxDecoration(
        //                   color: color.withValues(alpha: .18),
        //                   borderRadius: BorderRadius.circular(12),
        //                 ),
        //                 child: Icon(icon, color: color),
        //               ),
        //               const SizedBox(width: 10),
        //               Expanded(
        //                 child: Text(
        //                   title,
        //                   style: const TextStyle(
        //                       fontWeight: FontWeight.w800, fontSize: 15),
        //                   overflow: TextOverflow.ellipsis,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        //   separatorBuilder: (_, __) => const SizedBox(width: 2),
        //   itemCount: actions.length,
        // ),
        );
  }
}

class _SparklineCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> labels;
  final Color accent;
  final VoidCallback onViewAll;

  const _SparklineCard({
    required this.title,
    required this.data,
    required this.labels,
    required this.accent,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: accent),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              TextButton(onPressed: onViewAll, child: const Text("عرض الكل")),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _SparklinePainter(data: data, accent: accent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(labels.length, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 96),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: .5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color accent;

  _SparklinePainter({required this.data, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const maxV = 1.0; // البيانات 0..1
    final h = size.height - 22;

    final path = Path();
    final fill = Path();

    double dx(int i) => i * (size.width / (data.length - 1));
    double dy(double v) => size.height - 22 - (v / maxV) * h;

    // خط السباركلاين
    for (int i = 0; i < data.length; i++) {
      final x = dx(i);
      final y = dy(data[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    final paintFill = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: .28), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // ظل خفيف
    final paintShadow = Paint()
      ..color = accent.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, paintShadow);
    canvas.drawPath(fill, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.accent != accent;
  }
}

class _PillBottomNav extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PillBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final count = items.length;
      final itemW = w / count;
      final indicatorW = itemW * 0.86;
      final left = currentIndex * itemW + (itemW - indicatorW) / 2;

      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 18,
                offset: const Offset(0, 8)),
          ],
          border: Border.all(color: const Color(0x11000000)),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: left,
              top: 6,
              width: indicatorW,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Row(
              children: List.generate(count, (i) {
                final item = items[i];
                final selected = currentIndex == i;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onTap(i),
                    child: Container(
                      height: 64,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected
                                ? item['activeIcon'] as IconData
                                : item['icon'] as IconData,
                            color: selected
                                ? const Color(0xFF111827)
                                : const Color(0xFF6B7280),
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: selected
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_cubit.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_state.dart';
import 'package:manzoma/features/payroll/presentation/cubit/payroll_cubit.dart';
import 'package:manzoma/features/payroll/presentation/cubit/payroll_state.dart';
import 'package:manzoma/features/users/presentation/cubit/user_cubit.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSuperAdmin = false;
  String? _tenantId;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = SharedPrefHelper.getUser();
    if (user == null) return;

    if (user.role == UserRole.superAdmin) {
      setState(() => _isSuperAdmin = true);
      context.read<ClientCubit>().getClients();
    } else {
      setState(() => _tenantId = user.tenantId);
      _loadReportData();
    }
  }

  void _loadReportData() {
    if (_tenantId == null) return;
    context.read<UserCubit>().getUsers(tenantId: _tenantId);
    context.read<PayrollCubit>().fetchPayrolls(_tenantId!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التقارير والإحصائيات',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSuperAdmin ? 110.h : 50.h),
          child: Column(
            children: [
              if (_isSuperAdmin) _buildClientDropdown(),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
                  Tab(text: 'الحضور', icon: Icon(Icons.access_time)),
                  Tab(text: 'الرواتب', icon: Icon(Icons.payments)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _tenantId == null
          ? const Center(
              child: Text(
                'برجاء اختيار العميل',
                style: TextStyle(fontSize: 18),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAttendanceTab(),
                _buildPayrollTab(),
              ],
            ),
    );
  }

  Widget _buildClientDropdown() {
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) {
        if (state is ClientLoading) {
          return const LinearProgressIndicator();
        }
        if (state is ClientsLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: DropdownButtonFormField<String>(
              value: _tenantId,
              hint: const Text('اختر العميل', style: TextStyle(color: Colors.white70)),
              dropdownColor: const Color(0xFF2563EB),
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _tenantId = value);
                if (value != null) _loadReportData();
              },
              items: state.clients
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthSelector(),
          SizedBox(height: 16.h),
          _buildSummaryCards(),
          SizedBox(height: 24.h),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
            Text(
              '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        final employeeCount =
            userState is UserLoaded ? userState.users.length : 0;

        return BlocBuilder<PayrollCubit, PayrollState>(
          builder: (context, payrollState) {
            final payrolls = payrollState.payrolls;
            final totalSalaries = payrolls.fold<double>(
              0,
              (sum, p) => sum + p.netSalary,
            );
            final paidCount = payrolls.where((p) => p.status == 'paid').length;

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: 'إجمالي الموظفين',
                  value: '$employeeCount',
                  icon: Icons.people,
                  color: const Color(0xFF6366F1),
                ),
                _buildStatCard(
                  title: 'إجمالي الرواتب',
                  value: '${totalSalaries.toStringAsFixed(0)} ج.م',
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF10B981),
                ),
                _buildStatCard(
                  title: 'رواتب مدفوعة',
                  value: '$paidCount',
                  icon: Icons.check_circle,
                  color: const Color(0xFF22C55E),
                ),
                _buildStatCard(
                  title: 'رواتب معلقة',
                  value: '${payrolls.length - paidCount}',
                  icon: Icons.pending,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات سريعة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildStatRow(
              'متوسط ساعات العمل',
              '8 ساعات',
              Icons.schedule,
            ),
            const Divider(),
            _buildStatRow(
              'نسبة الحضور',
              '95%',
              Icons.trending_up,
            ),
            const Divider(),
            _buildStatRow(
              'إجمالي الإضافي',
              '120 ساعة',
              Icons.add_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20.sp),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontSize: 14.sp)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthSelector(),
          SizedBox(height: 16.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملخص الحضور',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildAttendanceStat('أيام الحضور', '22', Colors.green),
                  _buildAttendanceStat('أيام الغياب', '2', Colors.red),
                  _buildAttendanceStat('أيام التأخير', '3', Colors.orange),
                  _buildAttendanceStat('إجازات', '1', Colors.blue),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ساعات العمل',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildProgressBar('ساعات العمل الأساسية', 176, 200),
                  SizedBox(height: 12.h),
                  _buildProgressBar('ساعات إضافية', 24, 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontSize: 14.sp)),
          const Spacer(),
          Text(
            '$value يوم',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int total) {
    final percentage = (current / total * 100).clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14.sp)),
            Text(
              '$current / $total ساعة',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 100 ? Colors.green : const Color(0xFF2563EB),
          ),
          minHeight: 8.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
    );
  }

  Widget _buildPayrollTab() {
    return BlocBuilder<PayrollCubit, PayrollState>(
      builder: (context, state) {
        if (state.status == PayrollStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final payrolls = state.payrolls;
        final totalGross = payrolls.fold<double>(0, (sum, p) => sum + p.gross);
        final totalNet = payrolls.fold<double>(0, (sum, p) => sum + p.netSalary);
        final totalDeductions = totalGross - totalNet;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthSelector(),
              SizedBox(height: 16.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص الرواتب',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildPayrollSummaryRow(
                        'إجمالي المستحقات',
                        '${totalGross.toStringAsFixed(0)} ج.م',
                        const Color(0xFF10B981),
                      ),
                      const Divider(),
                      _buildPayrollSummaryRow(
                        'إجمالي الخصومات',
                        '${totalDeductions.toStringAsFixed(0)} ج.م',
                        Colors.red,
                      ),
                      const Divider(),
                      _buildPayrollSummaryRow(
                        'صافي الرواتب',
                        '${totalNet.toStringAsFixed(0)} ج.م',
                        const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالة الرواتب',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildPayrollStatusRow(
                        'مدفوعة',
                        payrolls.where((p) => p.status == 'paid').length,
                        Colors.green,
                      ),
                      _buildPayrollStatusRow(
                        'معتمدة',
                        payrolls.where((p) => p.status == 'approved').length,
                        Colors.blue,
                      ),
                      _buildPayrollStatusRow(
                        'مسودة',
                        payrolls.where((p) => p.status == 'draft').length,
                        Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayrollSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollStatusRow(String label, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$count راتب',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
}

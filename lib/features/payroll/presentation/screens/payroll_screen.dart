// payroll_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart';
import 'package:manzoma/core/theme/app_themes.dart';
import 'package:manzoma/features/auth/data/models/user_model.dart';
import 'package:manzoma/features/payroll/domain/entities/payroll_entity.dart';
import 'package:manzoma/features/payroll/presentation/cubit/payroll_cubit.dart';
import 'package:manzoma/features/payroll/presentation/cubit/payroll_state.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_cubit.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_state.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/features/users/presentation/cubit/user_cubit.dart';
import 'package:collection/collection.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  DateTime _selectedMonth = DateTime.now();
  String _filterStatus = 'All';
  bool _isSuperAdmin = false;
  String? _tenantId;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() {
    final user = SharedPrefHelper.getUser();
    if (user == null) return;
    if (user.role == UserRole.superAdmin) {
      _isSuperAdmin = true;
      context.read<ClientCubit>().getClients();
    } else {
      _tenantId = user.tenantId;
      context.read<PayrollCubit>().fetchPayrolls(_tenantId!);
    }
  }

  List<PayrollEntity> _filterPayrolls(List<PayrollEntity> payrolls) {
    return payrolls.where((p) {
      final monthMatch = p.periodStart.year == _selectedMonth.year &&
          p.periodStart.month == _selectedMonth.month;
      final statusMatch = _filterStatus == 'All' || p.status == _filterStatus;
      return monthMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return BlocBuilder<PayrollCubit, PayrollState>(
      builder: (context, state) {
        if (state.status == PayrollStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == PayrollStatus.failure) {
          return Center(child: Text(state.errorMessage ?? "حصل خطأ"));
        }

        final payrolls = _filterPayrolls(state.payrolls);

        final totalPaid = payrolls
            .where((p) => p.status == 'paid')
            .fold(0.0, (sum, p) => sum + p.netSalary.toDouble());

        final totalExpected =
            payrolls.fold(0.0, (sum, p) => sum + p.netSalary.toDouble());

        final employeeCount = payrolls.map((p) => p.userId).toSet().length;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text("لوحة الرواتب",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: g.onGlassPrimary)),
              actions: [
                IconButton(
                  tooltip: 'تحديث',
                  icon: Icon(Icons.refresh, color: g.onGlassPrimary),
                  onPressed: () {
                    if (_tenantId != null) {
                      context.read<PayrollCubit>().fetchPayrolls(_tenantId!);
                    }
                  },
                ),
              ],
              bottom: _isSuperAdmin
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(64),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: BlocBuilder<ClientCubit, ClientState>(
                          builder: (context, state) {
                            if (state is ClientLoading) {
                              return const LinearProgressIndicator();
                            } else if (state is ClientsLoaded) {
                              return DropdownButtonFormField<String>(
                                value: _tenantId,
                                hint: const Text("اختر العميل"),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: g.glass,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: g.glassBorder),
                                  ),
                                ),
                                items: state.clients
                                    .map((c) => DropdownMenuItem(
                                        value: c.id, child: Text(c.name)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _tenantId = val);
                                  if (val != null) {
                                    context
                                        .read<PayrollCubit>()
                                        .fetchPayrolls(val);
                                  }
                                },
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    )
                  : null,
            ),
            body: Stack(
              children: [
                const _BackgroundLayer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, kToolbarHeight + 24, 16, 16),
                  child: _tenantId == null
                      ? const Center(
                          child: Text(
                              "برجاء اختيار العميل أو تسجيل الدخول كـعميل"))
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HeaderCard(totalPaid: totalPaid, compliance: 72),
                              const SizedBox(height: 12),
                              _SummaryGrid(
                                  totalPaid: totalPaid,
                                  totalExpected: totalExpected,
                                  employeeCount: employeeCount),
                              const SizedBox(height: 16),
                              _FiltersRow(
                                selectedMonth: _selectedMonth,
                                filterStatus: _filterStatus,
                                onMonthPicked: (d) =>
                                    setState(() => _selectedMonth = d),
                                onStatusChanged: (s) =>
                                    setState(() => _filterStatus = s),
                              ),
                              const SizedBox(height: 16),
                              _PayrollTable(
                                  payrolls: payrolls, tenantId: _tenantId!),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          16),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: context.read<PayrollCubit>(),
                    child: PayrollDialog(tenantId: _tenantId!),
                  ),
                );
              },
              label: const Text("إضافة راتب أساسي"),
              icon: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}

/* --------------------
   Background & Header
   -------------------- */
class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [g.bgStart, g.bgEnd])),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final double totalPaid;
  final int compliance;
  const _HeaderCard({required this.totalPaid, required this.compliance});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    final date = DateTime.now().toLocal().toString().split(' ').first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: g.glass, border: Border.all(color: g.glassBorder)),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text("ملخص الرواتب",
                        style: TextStyle(color: g.onGlassSecondary)),
                    const SizedBox(height: 6),
                    Text("إدارة دفعات الرواتب",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: g.onGlassPrimary)),
                    const SizedBox(height: 8),
                    Text("التاريخ: $date",
                        style: TextStyle(color: g.onGlassSecondary)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: compliance / 100, minHeight: 6),
                    const SizedBox(height: 6),
                    Text("معدل الالتزام: $compliance%",
                        style: TextStyle(color: g.onGlassSecondary))
                  ])),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long),
                label: const Text("تصدير تقرير"),
                style: ElevatedButton.styleFrom(backgroundColor: g.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------
   Summary Grid
   -------------------- */
class _SummaryGrid extends StatelessWidget {
  final double totalPaid;
  final double totalExpected;
  final int employeeCount;
  const _SummaryGrid(
      {required this.totalPaid,
      required this.totalExpected,
      required this.employeeCount});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 4,
      children: [
        _StatCard(
            title: 'إجمالي المدفوع',
            value: '${totalPaid.toStringAsFixed(2)} EGP',
            icon: Icons.check_circle_outline),
        _StatCard(
            title: 'الإجمالي المتوقع',
            value: '${totalExpected.toStringAsFixed(2)} EGP',
            icon: Icons.account_balance_wallet),
        _StatCard(
            title: 'عدد الموظفين', value: '$employeeCount', icon: Icons.people),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          Icon(icon, size: 28, color: g.onGlassPrimary),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(title, style: TextStyle(color: g.onGlassSecondary)),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: g.onGlassPrimary)),
              ]))
        ]),
      ),
    );
  }
}

/* --------------------
   Filters Row
   -------------------- */
class _FiltersRow extends StatelessWidget {
  final DateTime selectedMonth;
  final String filterStatus;
  final ValueChanged<DateTime> onMonthPicked;
  final ValueChanged<String> onStatusChanged;

  const _FiltersRow(
      {required this.selectedMonth,
      required this.filterStatus,
      required this.onMonthPicked,
      required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    return Row(children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: filterStatus,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('الكل')),
            DropdownMenuItem(value: 'draft', child: Text('مسودة')),
            DropdownMenuItem(value: 'approved', child: Text('معتمد')),
            DropdownMenuItem(value: 'paid', child: Text('مدفوع')),
          ],
          onChanged: (v) {
            if (v != null) onStatusChanged(v);
          },
          decoration: InputDecoration(
              filled: true,
              fillColor: g.glass,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: g.glassBorder))),
        ),
      ),
      const SizedBox(width: 12),
      TextButton.icon(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedMonth,
            firstDate: DateTime(DateTime.now().year - 5),
            lastDate: DateTime(DateTime.now().year + 1),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
          );
          if (picked != null) onMonthPicked(picked);
        },
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text('${selectedMonth.month}/${selectedMonth.year}'),
        style: TextButton.styleFrom(
            backgroundColor: g.glass,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      )
    ]);
  }
}

/* --------------------
   Payroll Table
   -------------------- */
class _PayrollTable extends StatelessWidget {
  final List<PayrollEntity> payrolls;
  final String tenantId;

  const _PayrollTable({required this.payrolls, required this.tenantId});

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    if (payrolls.isEmpty) {
      return Center(
          child: Text("لا توجد كشوفات لهذا الشهر",
              style: TextStyle(color: g.onGlassSecondary)));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
              color: g.glass, border: Border.all(color: g.glassBorder)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('الموظف')),
                DataColumn(label: Text('الأساسي')),
                DataColumn(label: Text('الصافي')),
                DataColumn(label: Text('الحالة')),
                DataColumn(label: Text('إجراءات')),
              ],
              rows: payrolls.map((p) {
                return DataRow(cells: [
                  DataCell(Text(p.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${p.basicSalary} EGP')),
                  DataCell(Text('${p.netSalary} EGP')),
                  DataCell(_statusChip(p.status)),
                  DataCell(Row(children: [
                    IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        tooltip: "تفاصيل الراتب",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/payroll/employee/salary',
                            arguments: p,
                          );
                        }),
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                  value: context.read<PayrollCubit>(),
                                  child: PayrollDialog(
                                      tenantId: tenantId, payroll: p)));
                        }),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<PayrollCubit>().removePayroll(p.id);
                          context.read<PayrollCubit>().fetchPayrolls(tenantId);
                        }),
                  ])),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'مدفوع';
        break;
      case 'approved':
        color = Colors.indigo;
        label = 'معتمد';
        break;
      case 'draft':
      default:
        color = Colors.grey;
        label = 'مسودة';
    }
    return Chip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: color);
  }
}

/* --------------------
   Payroll Dialog (Add / Edit Basic Salary)
   -------------------- */
class PayrollDialog extends StatefulWidget {
  final String tenantId;
  final PayrollEntity? payroll;
  const PayrollDialog({super.key, required this.tenantId, this.payroll});

  @override
  State<PayrollDialog> createState() => _PayrollDialogState();
}

class _PayrollDialogState extends State<PayrollDialog> {
  final _formKey = GlobalKey<FormState>();
  UserModel? selectedUser;
  final TextEditingController _basicCtrl = TextEditingController();
  DateTime? _periodStart;
  DateTime? _periodEnd;
  String _status = 'draft';

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getUsers(tenantId: widget.tenantId);

    final p = widget.payroll;
    if (p != null) {
      _basicCtrl.text = p.basicSalary.toString();
      _periodStart = p.periodStart;
      _periodEnd = p.periodEnd;
      _status = p.status;
    } else {
      _periodStart = DateTime.now();
      _periodEnd = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _basicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.payroll != null;
    final cubit = context.read<PayrollCubit>();

    return AlertDialog(
      title: Text(isEdit ? 'تعديل راتب أساسي' : 'إضافة راتب أساسي'),
      content: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) return const CircularProgressIndicator();
          if (state is UserError) return Text("خطأ: ${state.message}");
          final users = state is UserLoaded ? state.users : [];

          if (isEdit && selectedUser == null && users.isNotEmpty) {
            selectedUser = users.firstWhereOrNull(
              (u) => u.id == widget.payroll!.userId,
            );
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<UserModel>(
                  value: selectedUser,
                  hint: const Text("اختر الموظف"),
                  items: (users as List<UserModel>)
                      .map((u) => DropdownMenuItem<UserModel>(
                            value: u,
                            child: Text(u.displayName),
                          ))
                      .toList(),
                  onChanged: (UserModel? val) =>
                      setState(() => selectedUser = val),
                  validator: (val) => val == null ? 'مطلوب' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _basicCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'الراتب الأساسي'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('مسودة')),
                    DropdownMenuItem(value: 'approved', child: Text('معتمد')),
                    DropdownMenuItem(value: 'paid', child: Text('مدفوع')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'draft'),
                ),
              ]),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;

            final payroll = PayrollEntity(
              id: widget.payroll?.id ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              tenantId: widget.tenantId,
              userId: selectedUser!.id,
              userName: selectedUser!.displayName,
              period:
                  '${_periodStart?.year}-${_periodStart?.month.toString().padLeft(2, '0')}',
              periodStart: _periodStart ?? DateTime.now(),
              periodEnd: _periodEnd ?? DateTime.now(),
              basicSalary: double.tryParse(_basicCtrl.text) ?? 0,
              gross: double.tryParse(_basicCtrl.text) ?? 0,
              netSalary:
                  double.tryParse(_basicCtrl.text) ?? 0, // مبدئياً = الأساسي
              workingDays: 0,
              actualWorkingDays: 0,
              status: _status,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            if (isEdit) {
              cubit.editPayroll(payroll);
            } else {
              cubit.addPayroll(payroll);
            }

            cubit.fetchPayrolls(widget.tenantId);
            Navigator.pop(context);
          },
          child: Text(isEdit ? 'حفظ' : 'إنشاء'),
        ),
      ],
    );
  }
}

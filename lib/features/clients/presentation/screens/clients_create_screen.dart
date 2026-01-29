import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../cubit/client_cubit.dart';
import '../cubit/client_state.dart';
import '../../domain/entities/client_entity.dart';

class ClientsCreateScreen extends StatefulWidget {
  final dynamic
      client; // هنستقبل ClientEntity (أو ClientModel) كـ extra وقت التعديل

  const ClientsCreateScreen({super.key, this.client});

  @override
  State<ClientsCreateScreen> createState() => _ClientsCreateScreenState();
}

class _ClientsCreateScreenState extends State<ClientsCreateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  // الحقول دي اختيارية في الواجهة فقط (مش موجودة في الموديل حالياً)
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _billingAmountController = TextEditingController();
  final _allowedBranchesController = TextEditingController();
  final _allowedUsersController = TextEditingController();
  final _subscriptionStartController = TextEditingController();
  final _subscriptionEndController = TextEditingController();

  // State
  String _selectedPlan = 'free';
  String _selectedBillingInterval = 'monthly';
  DateTime? _subscriptionStart;
  DateTime? _subscriptionEnd;
  int _selectedQuickRange = -1; // -1 = none

  // Animations
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool get _isEdit => widget.client is ClientEntity;

  @override
  void initState() {
    super.initState();

    if (_isEdit) {
      _fillFromClient(widget.client as ClientEntity);
    } else {
      _setDefaultsForCreate();
    }

    // Animations
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutQuad));
    _animCtrl.forward();
  }

  void _setDefaultsForCreate() {
    _subscriptionStart = DateTime.now();
    _subscriptionEnd = DateTime.now().add(const Duration(days: 365));
    _subscriptionStartController.text =
        DateFormat('yyyy-MM-dd').format(_subscriptionStart!);
    _subscriptionEndController.text =
        DateFormat('yyyy-MM-dd').format(_subscriptionEnd!);
    _billingAmountController.text = '0.00';
    _allowedBranchesController.text = '1';
    _allowedUsersController.text = '5';
    _selectedPlan = 'free';
    _selectedBillingInterval = 'monthly';
  }

  void _fillFromClient(ClientEntity c) {
    // خصائص متاحة في الموديل
    _nameController.text = c.name;
    _selectedPlan = c.plan;
    _selectedBillingInterval = c.billingInterval;

    _billingAmountController.text = c.billingAmount.toString();
    _allowedBranchesController.text = c.allowedBranches.toString();
    _allowedUsersController.text = c.allowedUsers.toString();

    _subscriptionStart = c.subscriptionStart;
    _subscriptionEnd = c.subscriptionEnd;

    if (_subscriptionStart != null) {
      _subscriptionStartController.text =
          DateFormat('yyyy-MM-dd').format(_subscriptionStart!);
    }
    if (_subscriptionEnd != null) {
      _subscriptionEndController.text =
          DateFormat('yyyy-MM-dd').format(_subscriptionEnd!);
    }

    // الحقول التالية غير موجودة في الموديل الحالي — هنسيبها فاضية
    _emailController.text = '';
    _phoneController.text = '';
    _websiteController.text = '';
    _addressController.text = '';
    _descriptionController.text = '';
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _billingAmountController.dispose();
    _allowedBranchesController.dispose();
    _allowedUsersController.dispose();
    _subscriptionStartController.dispose();
    _subscriptionEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return BlocProvider<ClientCubit>(
      create: (_) => sl<ClientCubit>(),
      child: Scaffold(
        backgroundColor: color.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: color.surface,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 16,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Icon(
                _isEdit ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                color: color.primary,
              ),
              const SizedBox(width: 8),
              Text(
                _isEdit ? 'تعديل عميل' : 'إضافة عميل',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: BlocBuilder<ClientCubit, ClientState>(
                builder: (context, state) {
                  final isLoading = state is ClientLoading;
                  return FilledButton.icon(
                    onPressed: isLoading ? null : _onSubmit,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_isEdit ? 'حفظ التغييرات' : 'حفظ'),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocConsumer<ClientCubit, ClientState>(
          listener: (context, state) async {
            if (!mounted) return;

            if (state is ClientCreated && !_isEdit) {
              _showSnack(context, 'تم إنشاء العميل بنجاح ✅', Colors.green);
              await Future.delayed(const Duration(milliseconds: 300));
              if (!mounted) return;
              context.go('/clients');
            } else if (state is ClientUpdated && _isEdit) {
              _showSnack(context, 'تم تحديث بيانات العميل ✅', Colors.green);
              await Future.delayed(const Duration(milliseconds: 300));
              if (!mounted) return;
              context.go('/clients');
            } else if (state is ClientError) {
              _showSnack(
                context,
                'حدث خطأ: ${state.message}',
                Theme.of(context).colorScheme.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ClientLoading;

            return Stack(
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _buildFormContent(context, isLoading),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: color.surface,
              border: Border(
                top: BorderSide(
                  color: color.outlineVariant,
                  width: 0.6,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: BlocBuilder<ClientCubit, ClientState>(
              builder: (context, state) {
                final isLoading = state is ClientLoading;
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _onSubmit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(_isEdit ? 'حفظ التغييرات' : 'إنشاء عميل'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 800;
        final EdgeInsets pad = EdgeInsets.all(isWide ? 24 : 16);

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120).add(pad),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionCard(
                      title: 'البيانات الأساسية',
                      icon: Icons.business_outlined,
                      child: Column(
                        children: [
                          _twoCol(
                            isWide,
                            _textField(
                              controller: _nameController,
                              label: 'اسم الشركة',
                              hint: 'أدخل اسم الشركة',
                              icon: Icons.badge_outlined,
                              required: true,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'هذا الحقل مطلوب'
                                  : null,
                            ),
                            _textField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني (اختياري)',
                              hint: 'example@mail.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final emailRe = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                return emailRe.hasMatch(v.trim())
                                    ? null
                                    : 'بريد إلكتروني غير صالح';
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            isWide,
                            _textField(
                              controller: _phoneController,
                              label: 'الهاتف (اختياري)',
                              hint: '+2012xxxxxxx',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            _textField(
                              controller: _websiteController,
                              label: 'الموقع الإلكتروني (اختياري)',
                              hint: 'https://example.com',
                              icon: Icons.language_rounded,
                              keyboardType: TextInputType.url,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _addressController,
                            label: 'العنوان (اختياري)',
                            hint: 'العنوان التفصيلي للشركة',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            controller: _descriptionController,
                            label: 'الوصف (اختياري)',
                            hint: 'وصف اختياري',
                            icon: Icons.notes_rounded,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'الخطة والفوترة',
                      icon: Icons.workspace_premium_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('خطة الاشتراك',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                  value: 'free',
                                  label: Text('مجاني'),
                                  icon: Icon(Icons.bolt_outlined)),
                              ButtonSegment(
                                  value: 'basic',
                                  label: Text('أساسي'),
                                  icon: Icon(Icons.star_border_rounded)),
                              ButtonSegment(
                                  value: 'premium',
                                  label: Text('محترف'),
                                  icon: Icon(Icons.workspace_premium_outlined)),
                              ButtonSegment(
                                  value: 'enterprise',
                                  label: Text('مؤسسات'),
                                  icon: Icon(Icons.apartment_rounded)),
                            ],
                            selected: <String>{_selectedPlan},
                            showSelectedIcon: false,
                            onSelectionChanged: (set) {
                              setState(() {
                                _selectedPlan = set.first;
                                if (_selectedPlan == 'free') {
                                  _billingAmountController.text = '0.00';
                                }
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                          const SizedBox(height: 16),
                          _twoCol(
                            isWide,
                            _textField(
                              controller: _billingAmountController,
                              label: 'مبلغ الفوترة',
                              hint: '0.00',
                              icon: Icons.payments_outlined,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              enabled: _selectedPlan != 'free',
                              helper: _selectedPlan == 'free'
                                  ? 'الخطة المجانية لا تتطلب فوترة'
                                  : null,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('الدورية',
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                                const SizedBox(height: 8),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                        value: 'monthly', label: Text('شهري')),
                                    ButtonSegment(
                                        value: 'quarterly',
                                        label: Text('ربع سنوي')),
                                    ButtonSegment(
                                        value: 'yearly', label: Text('سنوي')),
                                  ],
                                  selected: <String>{_selectedBillingInterval},
                                  onSelectionChanged: (set) {
                                    setState(() =>
                                        _selectedBillingInterval = set.first);
                                    HapticFeedback.selectionClick();
                                  },
                                  showSelectedIcon: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'الصلاحيات والتواريخ',
                      icon: Icons.admin_panel_settings_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _twoCol(
                            isWide,
                            _numberStepper(
                              label: 'عدد الفروع المسموح',
                              controller: _allowedBranchesController,
                              min: 1,
                              max: 999,
                            ),
                            _numberStepper(
                              label: 'عدد المستخدمين المسموح',
                              controller: _allowedUsersController,
                              min: 1,
                              max: 9999,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('فترة الاشتراك',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('شهر'),
                                selected: _selectedQuickRange == 0,
                                onSelected: (_) => _applyQuickRange(0),
                              ),
                              ChoiceChip(
                                label: const Text('3 أشهر'),
                                selected: _selectedQuickRange == 1,
                                onSelected: (_) => _applyQuickRange(1),
                              ),
                              ChoiceChip(
                                label: const Text('6 أشهر'),
                                selected: _selectedQuickRange == 2,
                                onSelected: (_) => _applyQuickRange(2),
                              ),
                              ChoiceChip(
                                label: const Text('سنة'),
                                selected: _selectedQuickRange == 3,
                                onSelected: (_) => _applyQuickRange(3),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _selectDateRange(context),
                                icon: const Icon(Icons.date_range_rounded),
                                label: const Text('اختيار فترة'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            isWide,
                            _textField(
                              controller: _subscriptionStartController,
                              label: 'تاريخ البداية',
                              icon: Icons.calendar_today_outlined,
                              readOnly: true,
                              onTap: () => _selectSingleDate(context, true),
                            ),
                            _textField(
                              controller: _subscriptionEndController,
                              label: 'تاريخ النهاية',
                              icon: Icons.event_outlined,
                              readOnly: true,
                              onTap: () => _selectSingleDate(context, false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- Widgets Helpers ----------

  Widget _sectionCard(
      {required String title, required IconData icon, required Widget child}) {
    final color = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: color.surface,
      surfaceTintColor: color.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: color.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _twoCol(bool isWide, Widget left, Widget right) {
    if (!isWide) {
      return Column(
        children: [
          left,
          const SizedBox(height: 12),
          right,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helper,
    IconData? icon,
    bool required = false,
    bool readOnly = false,
    bool enabled = true,
    GestureTapCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator ??
          (required
              ? (v) =>
                  (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
              : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _numberStepper({
    required String label,
    required TextEditingController controller,
    int min = 0,
    int max = 9999,
  }) {
    void setVal(int v) {
      v = v.clamp(min, max);
      controller.text = v.toString();
    }

    int getVal() => int.tryParse(controller.text.trim()) ?? min;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'نقص',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setVal(getVal() - 1);
                },
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'زيادة',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setVal(getVal() + 1);
                },
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- Dates ----------

  Future<void> _selectSingleDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime initial =
        isStart ? (_subscriptionStart ?? now) : (_subscriptionEnd ?? now);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      helpText: isStart ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
    if (picked != null) {
      setState(() {
        _selectedQuickRange = -1;
        if (isStart) {
          _subscriptionStart = picked;
          _subscriptionStartController.text =
              DateFormat('yyyy-MM-dd').format(picked);
          if (_subscriptionEnd != null && _subscriptionEnd!.isBefore(picked)) {
            _subscriptionEnd = picked.add(const Duration(days: 30));
            _subscriptionEndController.text =
                DateFormat('yyyy-MM-dd').format(_subscriptionEnd!);
          }
        } else {
          _subscriptionEnd = picked;
          _subscriptionEndController.text =
              DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime start = _subscriptionStart ?? now;
    final DateTime end = _subscriptionEnd ?? now.add(const Duration(days: 30));
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      initialDateRange: DateTimeRange(start: start, end: end),
      helpText: 'اختر فترة الاشتراك',
      saveText: 'تأكيد',
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
    if (picked != null) {
      setState(() {
        _selectedQuickRange = -1;
        _subscriptionStart = picked.start;
        _subscriptionEnd = picked.end;
        _subscriptionStartController.text =
            DateFormat('yyyy-MM-dd').format(picked.start);
        _subscriptionEndController.text =
            DateFormat('yyyy-MM-dd').format(picked.end);
      });
    }
  }

  void _applyQuickRange(int index) {
    setState(() {
      _selectedQuickRange = index;
      final start = _subscriptionStart ?? DateTime.now();
      Duration d;
      switch (index) {
        case 0:
          d = const Duration(days: 30);
          break;
        case 1:
          d = const Duration(days: 90);
          break;
        case 2:
          d = const Duration(days: 180);
          break;
        case 3:
          d = const Duration(days: 365);
          break;
        default:
          d = const Duration(days: 30);
      }
      _subscriptionStart = start;
      _subscriptionEnd = start.add(d);
      _subscriptionStartController.text =
          DateFormat('yyyy-MM-dd').format(_subscriptionStart!);
      _subscriptionEndController.text =
          DateFormat('yyyy-MM-dd').format(_subscriptionEnd!);
      HapticFeedback.selectionClick();
    });
  }

  // ---------- Actions ----------

  void _onSubmit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showSnack(context, 'يرجى استكمال الحقول المطلوبة',
          Theme.of(context).colorScheme.error);
      return;
    }

    final billingAmount =
        double.tryParse(_billingAmountController.text.trim()) ?? 0.0;
    final allowedBranches =
        int.tryParse(_allowedBranchesController.text.trim()) ?? 1;
    final allowedUsers = int.tryParse(_allowedUsersController.text.trim()) ?? 5;

    if (_subscriptionStart == null || _subscriptionEnd == null) {
      _showSnack(context, 'يرجى اختيار تواريخ الاشتراك',
          Theme.of(context).colorScheme.error);
      return;
    }
    if (!_subscriptionEnd!.isAfter(_subscriptionStart!) &&
        !_isSameDay(_subscriptionEnd!, _subscriptionStart!)) {
      _showSnack(context, 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية',
          Theme.of(context).colorScheme.error);
      return;
    }

    if (_isEdit) {
      final id = (widget.client as ClientEntity).id;
      context.read<ClientCubit>().updateClient(
            id: id,
            name: _nameController.text.trim(),
            plan: _selectedPlan,
            subscriptionStart: _subscriptionStart!,
            subscriptionEnd: _subscriptionEnd!,
            billingAmount: billingAmount,
            billingInterval: _selectedBillingInterval,
            allowedBranches: allowedBranches,
            allowedUsers: allowedUsers,
          );
    } else {
      context.read<ClientCubit>().createClient(
            name: _nameController.text.trim(),
            plan: _selectedPlan,
            subscriptionStart: _subscriptionStart!,
            subscriptionEnd: _subscriptionEnd!,
            billingAmount: billingAmount,
            billingInterval: _selectedBillingInterval,
            allowedBranches: allowedBranches,
            allowedUsers: allowedUsers,
          );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showSnack(BuildContext context, String msg, Color bg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/enums/user_role.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/shared_pref_helper.dart';
import 'package:manzoma/core/entities/user_entity.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';

import '../../../clients/presentation/cubit/client_cubit.dart';
import '../../../clients/presentation/cubit/client_state.dart';
import '../../../clients/domain/entities/client_entity.dart';

import '../cubit/branch_cubit.dart';
import '../../domain/entities/branch_entity.dart';

class BranchesCreateScreen extends StatefulWidget {
  const BranchesCreateScreen({super.key});

  @override
  State<BranchesCreateScreen> createState() => _BranchesCreateScreenState();
}

class _BranchesCreateScreenState extends State<BranchesCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers: الأساسية
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _managerController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Controllers: الإحداثيات/نصف القطر/لينك الماب
  final _mapsUrlController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController(text: '100'); // افتراضي 100م

  ClientEntity? _selectedClient;
  UserEntity? _currentUser;
  bool _isSuperAdmin = false;
  // --- جديد: متغير لتتبع حالة تجاوز الحد ---
  bool _isLimitReached = false;

  late final BranchCubit _branchCubit;
  late final ClientCubit _clientCubit;

  @override
  void initState() {
    super.initState();
    _branchCubit = getIt<BranchCubit>();
    _clientCubit = getIt<ClientCubit>();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = SharedPrefHelper.getUser();
    if (user != null) {
      _currentUser = user;
      _isSuperAdmin = user.role == UserRole.superAdmin;

      if (_isSuperAdmin) {
        _clientCubit.getClients();
      } else {
        // --- معدّل: تم استبدال الكود المكرر ---
        final clientForUser = ClientEntity(
          id: user.tenantId,
          name: "My Company",
          plan: "Free",
          subscriptionStart: DateTime.now(),
          subscriptionEnd: DateTime.now().add(const Duration(days: 30)),
          billingAmount: 0,
          billingInterval: "monthly",
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          allowedBranches: 1, // مثال
          allowedUsers: 1, // مثال
          currentBranches: 1, // مثال
          currentUsers: 1, // مثال
        );
        setState(() {
          _selectedClient = clientForUser;
          // --- جديد: التحقق من الحدود عند التحميل للمستخدم العادي ---
          _updateClientLimits(_selectedClient);
        });
      }
    }
  }

  // --- جديد: دالة مركزية للتحقق من حدود العميل ---
  void _updateClientLimits(ClientEntity? client) {
    if (client == null) {
      setState(() => _isLimitReached = false);
      return;
    }
    final allowed = client.allowedBranches;
    final current = client.currentBranches;
    final remaining = (current != null) ? (allowed - current) : 1;
    setState(() => _isLimitReached = remaining <= 0);
  }

  @override
  void dispose() {
    _branchCubit.close();
    _clientCubit.close();

    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _managerController.dispose();
    _descriptionController.dispose();

    _mapsUrlController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _branchCubit),
        BlocProvider.value(value: _clientCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Branch'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/branches'),
          ),
        ),
        body: BlocConsumer<BranchCubit, BranchState>(
          listener: (context, state) {
            if (state is BranchCreated) {
              final clientName = _selectedClient?.name ??
                  _currentUser?.tenantId ??
                  "Unknown Client";

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Branch "${state.branch.name}" created successfully for $clientName!',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              context.go('/branches');
            } else if (state is BranchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is BranchLoading;

            return Stack(
              children: [
                _buildForm(context, isLoading),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth > 600 ? 32 : 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(Icons.location_city,
                                size: 32,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create New Branch',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Add a new branch to the system',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // اختيار العميل
                        buildClientSelection(),

                        const SizedBox(height: 16),

                        // ---- معلومات حدود العميل (مسموح/متبقي) ----
                        _buildClientLimitsStrip(),

                        // --- جديد: إظهار رسالة التحذير عند تجاوز الحد ---
                        _buildLimitWarning(),

                        const SizedBox(height: 24),

                        // --- معدّل: تمرير حالة التعطيل للحقول ---
                        buildResponsiveGeneralFields(
                            constraints, _isLimitReached),

                        const SizedBox(height: 24),

                        // --- معدّل: تمرير حالة التعطيل للحقول ---
                        _buildGeoSection(constraints, _isLimitReached),

                        const SizedBox(height: 32),

                        // --- معدّل: تمرير حالة التعطيل للأزرار ---
                        buildActionButtons(
                            context, isLoading, _isLimitReached, constraints),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ======= UI: شرائط معلومات حدود العميل =======
  Widget _buildClientLimitsStrip() {
    final allowed = _selectedClient?.allowedBranches;
    final current = _selectedClient?.currentBranches;
    final remaining =
        (allowed != null && current != null) ? (allowed - current) : null;

    return Row(
      children: [
        _miniInfoCard(
          title: 'Allowed branches',
          value: allowed?.toString() ?? '--',
          icon: Icons.verified,
        ),
        const SizedBox(width: 12),
        _miniInfoCard(
          title: 'Remaining',
          value: remaining?.toString() ?? '--',
          icon: Icons.pending_actions,
          valueColor:
              (remaining != null && remaining <= 0) ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  // --- جديد: عنصر واجهة المستخدم الخاص برسالة التحذير ---
  Widget _buildLimitWarning() {
    if (!_isLimitReached) {
      // لا تظهر أي شيء إذا لم يتم الوصول إلى الحد الأقصى
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Branch limit reached. All fields are disabled.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======= UI: اختيار العميل =======
  Widget buildClientSelection() {
    if (_isSuperAdmin) {
      return BlocBuilder<ClientCubit, ClientState>(
        builder: (context, state) {
          if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClientsLoaded) {
            // --- معدّل: منطق لاختيار أول عميل تلقائيًا وتحديث الحدود ---
            if (_selectedClient == null && state.clients.isNotEmpty) {
              _selectedClient = state.clients.first;
              // استخدام PostFrameCallback لتحديث الحالة بأمان بعد مرحلة البناء
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _updateClientLimits(_selectedClient);
                }
              });
            }
            return buildClientDropdown(state.clients, _selectedClient);
          }
          return Container();
        },
      );
    } else {
      // بالنسبة للمستخدم العادي، يتم عرض العميل الخاص به فقط
      if (_selectedClient != null) {
        return buildClientDropdown([_selectedClient!], _selectedClient,
            isEnabled: false); // غير قابل للتغيير
      }
      return Container();
    }
  }

  Widget buildClientDropdown(List<ClientEntity> clients, ClientEntity? initial,
      {bool isEnabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Client',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ClientEntity>(
          value: initial,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: const OutlineInputBorder(),
            hintText: 'Choose a client',
            filled: !isEnabled,
            fillColor: Colors.grey.shade200,
          ),
          items: clients
              .map((client) => DropdownMenuItem<ClientEntity>(
                    value: client,
                    child: Text(client.name),
                  ))
              .toList(),
          // --- معدّل: يتم تحديث الحدود عند تغيير العميل ---
          onChanged: isEnabled
              ? (ClientEntity? newValue) {
                  setState(() => _selectedClient = newValue);
                  _updateClientLimits(newValue);
                }
              : null,
          validator: (value) => value == null ? 'Please select a client' : null,
        ),
      ],
    );
  }

  // ======= UI: الحقول العامة =======
  // --- معدّل: استقبال متغير للتحكم في حالة التعطيل ---
  Widget buildResponsiveGeneralFields(
      BoxConstraints constraints, bool isDisabled) {
    final isWideScreen = constraints.maxWidth > 700;

    return AbsorbPointer(
      absorbing: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: isWideScreen
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          controller: _nameController,
                          label: 'Branch Name',
                          hintText: 'Enter branch name',
                          prefixIcon: Icons.business,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter branch name'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomInput(
                          controller: _phoneController,
                          label: 'Phone',
                          hintText: 'Enter phone number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Enter email address',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final ok =
                                  RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$')
                                      .hasMatch(value);
                              if (!ok) return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomInput(
                          controller: _managerController,
                          label: 'Manager Name',
                          hintText: 'Enter manager name',
                          prefixIcon: Icons.person,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _addressController,
                    label: 'Address',
                    hintText: 'Enter branch address',
                    prefixIcon: Icons.location_on,
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter branch address'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Enter branch description (optional)',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              )
            : Column(
                children: [
                  CustomInput(
                    controller: _nameController,
                    label: 'Branch Name',
                    hintText: 'Enter branch name',
                    prefixIcon: Icons.business,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter branch name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _phoneController,
                    label: 'Phone',
                    hintText: 'Enter phone number',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter email address',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$')
                            .hasMatch(value);
                        if (!ok) return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _managerController,
                    label: 'Manager Name',
                    hintText: 'Enter manager name',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _addressController,
                    label: 'Address',
                    hintText: 'Enter branch address',
                    prefixIcon: Icons.location_on,
                    maxLines: 2,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter branch address'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Enter branch description (optional)',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
      ),
    );
  }

  // ======= UI: قسم الإحداثيات واللينك ونصف القطر =======
  // --- معدّل: استقبال متغير للتحكم في حالة التعطيل ---
  Widget _buildGeoSection(BoxConstraints constraints, bool isDisabled) {
    final isWideScreen = constraints.maxWidth > 700;

    final mapsField = CustomInput(
      controller: _mapsUrlController,
      label: 'Google Maps URL',
      hintText:
          'Paste a Google Maps link here (supports @lat,lng, ?q=lat,lng, !3dlat!4dlng)',
      prefixIcon: Icons.link,
      suffixIcon: IconButton(
        icon: const Icon(Icons.paste),
        onPressed: () async {
          final data = await Clipboard.getData('text/plain');
          final text = data?.text ?? '';
          if (text.isNotEmpty) {
            setState(() {
              _mapsUrlController.text = text.trim();
            });
            _extractLatLngFromUrl();
          }
        },
      ),
      onChanged: (_) => _extractLatLngFromUrl(),
    );

    final latField = CustomInput(
      controller: _latitudeController,
      label: 'Latitude',
      hintText: 'e.g. 30.0444',
      prefixIcon: Icons.my_location,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Latitude required';
        final d = double.tryParse(v.trim());
        if (d == null || d < -90 || d > 90)
          return 'Latitude must be between -90 and 90';
        return null;
      },
    );

    final lngField = CustomInput(
      controller: _longitudeController,
      label: 'Longitude',
      hintText: 'e.g. 31.2357',
      prefixIcon: Icons.explore,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Longitude required';
        final d = double.tryParse(v.trim());
        if (d == null || d < -180 || d > 180)
          return 'Longitude must be between -180 and 180';
        return null;
      },
    );

    final radiusField = CustomInput(
      controller: _radiusController,
      label: 'Radius (meters)',
      hintText: 'e.g. 100',
      prefixIcon: Icons.circle,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Radius required';
        final n = int.tryParse(v.trim());
        if (n == null || n <= 0) return 'Radius must be a positive number';
        return null;
      },
    );

    return AbsorbPointer(
      absorbing: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Location & Geofence'),
            const SizedBox(height: 8),
            mapsField,
            const SizedBox(height: 16),
            if (isWideScreen)
              Row(
                children: [
                  Expanded(child: latField),
                  const SizedBox(width: 16),
                  Expanded(child: lngField),
                  const SizedBox(width: 16),
                  Expanded(child: radiusField),
                ],
              )
            else ...[
              latField,
              const SizedBox(height: 16),
              lngField,
              const SizedBox(height: 16),
              radiusField,
            ],
            const SizedBox(height: 4),
            const Text(
              'Tip: paste a Google Maps link, we will auto-fill latitude & longitude.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );

  // ======= زرارين =======
  // --- معدّل: استقبال متغير للتحكم في حالة التعطيل ---
  Widget buildActionButtons(BuildContext context, bool isLoading,
      bool isDisabled, BoxConstraints constraints) {
    final isWideScreen = constraints.maxWidth > 600;

    final createBtn = CustomButton(
      text: 'Create Branch',
      // --- معدّل: إضافة شرط التعطيل الجديد ---
      onPressed: isLoading || isDisabled ? null : _onCreatePressed,
      isLoading: isLoading,
      icon: Icons.add,
    );

    final cancelBtn = OutlinedButton(
      // زر الإلغاء يظل فعالاً دائمًا
      onPressed: isLoading ? null : () => context.go('/branches'),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text('Cancel'),
      ),
    );

    return isWideScreen
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              cancelBtn,
              const SizedBox(width: 16),
              createBtn,
            ],
          )
        : Column(
            children: [
              SizedBox(width: double.infinity, child: createBtn),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: cancelBtn),
            ],
          );
  }

  // ======= المنطق: استخراج الإحداثيات من لينك جوجل =======
  void _extractLatLngFromUrl() {
    final url = _mapsUrlController.text.trim();
    if (url.isEmpty) return;

    // 1) .../@lat,lng,z
    final atMatch = RegExp(r'@(-?\d+\.?\d*),\s*(-?\d+\.?\d*)').firstMatch(url);

    // 2) ...?q=lat,lng  أو &q=lat,lng
    final qMatch =
        RegExp(r'[?&]q=(-?\d+\.?\d*),\s*(-?\d+\.?\d*)').firstMatch(url);

    // 3) ...!3dlat!4dlng
    final bangMatch =
        RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)').firstMatch(url);

    double? lat;
    double? lng;

    if (atMatch != null) {
      lat = double.tryParse(atMatch.group(1)!);
      lng = double.tryParse(atMatch.group(2)!);
    } else if (qMatch != null) {
      lat = double.tryParse(qMatch.group(1)!);
      lng = double.tryParse(qMatch.group(2)!);
    } else if (bangMatch != null) {
      lat = double.tryParse(bangMatch.group(1)!);
      lng = double.tryParse(bangMatch.group(2)!);
    }

    if (lat != null && lng != null) {
      setState(() {
        _latitudeController.text = lat!.toStringAsFixed(6);
        _longitudeController.text = lng!.toStringAsFixed(6);
      });
    }
  }

  // ======= إنشاء الفرع =======
  void _onCreatePressed() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_isSuperAdmin && _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- ملحوظة: لم نعد بحاجة للتحقق من الحدود هنا لأن الزر سيكون معطلاً ---

    final lat = double.parse(_latitudeController.text.trim());
    final lng = double.parse(_longitudeController.text.trim());
    final radius = double.parse(_radiusController.text.trim());

    final branch = BranchEntity(
      id: '',
      tenantId: _selectedClient?.id ?? _currentUser?.tenantId ?? '',
      name: _nameController.text.trim(),
      latitude: lat,
      longitude: lng,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      radiusMeters: radius,
      details: {
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'manager': _managerController.text.trim(),
        'description': _descriptionController.text.trim(),
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _branchCubit.createBranch(branch);
  }
}

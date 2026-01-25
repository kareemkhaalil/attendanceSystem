import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manzoma/core/enums/user_role.dart';
import 'package:manzoma/core/di/injection_container.dart';
import 'package:manzoma/core/storage/shared_pref_helper.dart' as sp;

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../clients/presentation/cubit/client_cubit.dart';
import '../../../clients/presentation/cubit/client_state.dart';
import '../cubit/branch_cubit.dart';
import '../../domain/entities/branch_entity.dart';

class BranchesEditScreen extends StatefulWidget {
  final BranchEntity editingBranch;

  const BranchesEditScreen({super.key, required this.editingBranch});

  @override
  State<BranchesEditScreen> createState() => _BranchesEditScreenState();
}

class _BranchesEditScreenState extends State<BranchesEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _managerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapsUrlController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();

  ClientEntity? _selectedClient;
  bool _isSuperAdmin = false;
  String? _tenantId; // To hold the branch's original tenantId

  late final BranchCubit _branchCubit;
  late final ClientCubit _clientCubit;

  @override
  void initState() {
    super.initState();
    _branchCubit = getIt<BranchCubit>();
    _clientCubit = getIt<ClientCubit>();

    // تحميل بيانات الفرع المراد تعديله في الحقول
    _loadBranchData(widget.editingBranch);

    // تحميل بيانات العميل بناءً على دور المستخدم الحالي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClientData();
    });
  }

  void _loadBranchData(BranchEntity branch) {
    _nameController.text = branch.name;
    _addressController.text = branch.address ?? '';
    _latitudeController.text = branch.latitude.toString();
    _longitudeController.text = branch.longitude.toString();
    _radiusController.text = branch.radiusMeters.toStringAsFixed(0);
    _tenantId = branch.tenantId;

    // Load details from the map
    _phoneController.text = branch.details['phone'] ?? '';
    _emailController.text = branch.details['email'] ?? '';
    _managerController.text = branch.details['manager'] ?? '';
    _descriptionController.text = branch.details['description'] ?? '';

    if (mounted) setState(() {});
  }

  void _loadClientData() {
    final currentUser = sp.SharedPrefHelper.getUser();
    if (currentUser != null) {
      if (mounted) {
        setState(() {
          _isSuperAdmin = currentUser.role == UserRole.superAdmin;
        });
      }

      if (_isSuperAdmin) {
        // إذا كان super admin، يتم جلب كل العملاء لتحديد العميل الخاص بالفرع
        _clientCubit.getClients();
      } else {
        // إذا لم يكن super admin، يتم جلب العميل المحدد فقط
        _clientCubit.getClientById(widget.editingBranch.tenantId);
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
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
          title: const Text('تعديل الفرع'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/branches'),
          ),
        ),
        body: BlocConsumer<BranchCubit, BranchState>(
          listener: (context, state) {
            if (state is BranchUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('✅ تم تعديل الفرع "${state.branch.name}" بنجاح!'),
                  backgroundColor: Colors.green,
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
                            Icon(Icons.edit_location_alt,
                                size: 32,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit Branch',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Modify branch details in the system',
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
                        buildClientField(),
                        const SizedBox(height: 24),
                        buildResponsiveGeneralFields(constraints),
                        const SizedBox(height: 24),
                        _buildGeoSection(constraints),
                        const SizedBox(height: 32),
                        buildActionButtons(context, isLoading, constraints),
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

  Widget buildClientField() {
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) {
        if (_isSuperAdmin) {
          if (state is ClientsLoaded) {
            final clients = state.clients;
            if (clients.isEmpty) return const SizedBox.shrink();

            ClientEntity? initialSelection;
            try {
              initialSelection = clients.firstWhere((c) => c.id == _tenantId);
            } catch (e) {
              initialSelection = clients.isNotEmpty ? clients.first : null;
            }

            return DropdownButtonFormField<ClientEntity>(
              value: _selectedClient ?? initialSelection,
              decoration: const InputDecoration(
                labelText: 'اختر العميل',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: clients
                  .map((client) => DropdownMenuItem<ClientEntity>(
                        value: client,
                        child: Text(client.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedClient = value);
              },
            );
          } else if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Text('⚠️ لا توجد بيانات عملاء');
        } else {
          // For non-superadmin, show a read-only field
          if (state is ClientLoaded) {
            _selectedClient = state.client;
            return TextFormField(
              initialValue: state.client.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                labelText: 'العميل',
                filled: true,
              ),
              readOnly: true,
            );
          } else if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Text('⚠️ لم يتم العثور على عميل لهذا الفرع');
        }
      },
    );
  }

  // --- باقي الـ Widgets (buildResponsiveGeneralFields, _buildGeoSection, etc.) ---
  // --- يتم نسخها كما هي من ملف `branches_create_screen.dart` ---
  // --- سأقوم بلصقها هنا للاكتمال مع تعديل بسيط على زر الحفظ ---

  Widget buildResponsiveGeneralFields(BoxConstraints constraints) {
    final isWideScreen = constraints.maxWidth > 700;
    // ... (نفس الكود من صفحة الإنشاء بدون تغيير)
    // For brevity, this is omitted but you should copy the exact same widget here.
    return isWideScreen
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
                          final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$')
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
          );
  }

  Widget _buildGeoSection(BoxConstraints constraints) {
    // ... (نفس الكود من صفحة الإنشاء بدون تغيير)
    // For brevity, this is omitted but you should copy the exact same widget here.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text("Location & Geofence",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
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
    );
  }

  Widget buildActionButtons(
      BuildContext context, bool isLoading, BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isLoading ? null : () => context.go('/branches'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        CustomButton(
          text: 'Update Branch', // <--- تغيير النص
          onPressed: isLoading ? null : _onUpdatePressed, // <--- تغيير الدالة
          isLoading: isLoading,
          icon: Icons.save, // <--- تغيير الأيقونة
        ),
      ],
    );
  }

  void _extractLatLngFromUrl() {
    // ... (نفس الكود من صفحة الإنشاء بدون تغيير)
    // For brevity, this is omitted but you should copy the exact same function here.
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

  void _onUpdatePressed() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client information is missing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lat = double.parse(_latitudeController.text.trim());
    final lng = double.parse(_longitudeController.text.trim());
    final radius = double.parse(_radiusController.text.trim());

    final updatedBranch = BranchEntity(
      id: widget.editingBranch.id, // <--- استخدام الـ ID الأصلي
      tenantId: _selectedClient!.id,
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
      createdAt:
          widget.editingBranch.createdAt, // <--- استخدام تاريخ الإنشاء الأصلي
      updatedAt: DateTime.now(), // <--- تحديث تاريخ التعديل
    );

    // استدعاء دالة التحديث في الـ Cubit
    // _branchCubit.updateBranch(updatedBranch);
  }
}

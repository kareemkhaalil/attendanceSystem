// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../domain/entities/branch_entity.dart';
// import '../cubit/branch_cubit.dart';

// class AddBranchDialog extends StatefulWidget {
//   const AddBranchDialog({super.key});

//   @override
//   State<AddBranchDialog> createState() => _AddBranchDialogState();
// }

// class _AddBranchDialogState extends State<AddBranchDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _latitudeController = TextEditingController();
//   final _longitudeController = TextEditingController();
//   final _radiusController = TextEditingController(text: '5');

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _addressController.dispose();
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     _radiusController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.r),
//       ),
//       child: Container(
//         width: 500.w,
//         padding: EdgeInsets.all(24.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Icon(
//                   Icons.store_mall_directory,
//                   size: 24.w,
//                   color: const Color(0xFF2563EB),
//                 ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   'إضافة فرع جديد',
//                   style: TextStyle(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24.h),
//             // Form
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Name Field
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'اسم الفرع *',
//                       prefixIcon: const Icon(Icons.store),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'يرجى إدخال اسم الفرع';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 16.h),
//                   // Address Field
//                   TextFormField(
//                     controller: _addressController,
//                     decoration: InputDecoration(
//                       labelText: 'العنوان',
//                       prefixIcon: const Icon(Icons.location_on),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                     ),
//                     maxLines: 2,
//                   ),
//                   SizedBox(height: 16.h),
//                   // Coordinates Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _latitudeController,
//                           decoration: InputDecoration(
//                             labelText: 'خط العرض *',
//                             prefixIcon: const Icon(Icons.gps_fixed),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'مطلوب';
//                             }
//                             final lat = double.tryParse(value);
//                             if (lat == null || lat < -90 || lat > 90) {
//                               return 'خط عرض غير صحيح';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _longitudeController,
//                           decoration: InputDecoration(
//                             labelText: 'خط الطول *',
//                             prefixIcon: const Icon(Icons.gps_fixed),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.r),
//                             ),
//                           ),
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'مطلوب';
//                             }
//                             final lng = double.tryParse(value);
//                             if (lng == null || lng < -180 || lng > 180) {
//                               return 'خط طول غير صحيح';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16.h),
//                   // Radius Field
//                   TextFormField(
//                     controller: _radiusController,
//                     decoration: InputDecoration(
//                       labelText: 'نطاق الحضور (متر)',
//                       prefixIcon: const Icon(Icons.radio_button_checked),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       helperText: 'المسافة المسموحة للحضور من موقع الفرع',
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value != null && value.isNotEmpty) {
//                         final radius = double.tryParse(value);
//                         if (radius == null || radius <= 0) {
//                           return 'يرجى إدخال نطاق صحيح';
//                         }
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 16.h),
//                   // Location Helper
//                   Container(
//                     padding: EdgeInsets.all(12.w),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           color: Colors.blue,
//                           size: 20.w,
//                         ),
//                         SizedBox(width: 8.w),
//                         Expanded(
//                           child: Text(
//                             'يمكنك الحصول على الإحداثيات من خرائط جوجل',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color: Colors.blue[700],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 24.h),
//             // Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: Text(
//                       'إلغاء',
//                       style: TextStyle(fontSize: 16.sp),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _createBranch,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2563EB),
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(vertical: 12.h),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                     ),
//                     child: Text(
//                       'إضافة',
//                       style: TextStyle(fontSize: 16.sp),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _createBranch() {
//     if (_formKey.currentState!.validate()) {
//       final branch = BranchEntity(
//         id: '', // Will be generated by Supabase
//         tenantId: 'default-tenant', // TODO: Get from current user context
//         name: _nameController.text.trim(),
//         latitude: double.parse(_latitudeController.text),
//         longitude: double.parse(_longitudeController.text),
//         address: _addressController.text.trim().isEmpty 
//             ? null 
//             : _addressController.text.trim(),
//         radiusMeters: _radiusController.text.isEmpty 
//             ? 5.0 
//             : double.parse(_radiusController.text),
//       );

//       context.read<BranchCubit>().createBranch(branch);
//       Navigator.of(context).pop();
      
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم إضافة الفرع بنجاح'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }
// }

